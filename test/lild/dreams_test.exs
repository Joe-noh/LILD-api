defmodule LILD.DreamsTest do
  use LILD.DataCase, async: true

  alias LILD.{Dreams, Accounts}
  alias LILD.Dreams.{Dream, Tag, Report}

  setup [:create_user, :create_dreams]

  describe "dreams_query" do
    test "ユーザの夢をすべて返すクエリを返す", %{user: user} do
      user_dreams = user |> Ecto.assoc(:dreams) |> Repo.all()

      Dreams.dreams_query(user)
      |> Repo.all()
      |> Enum.each(fn dream ->
        assert dream.id in Enum.map(user_dreams, & &1.id)
      end)
    end

    test "タグのついた夢をすべて返すクエリを返す", %{tags: [tag | _]} do
      tagged_dreams = tag |> Ecto.assoc(:dreams) |> Repo.all()

      Dreams.dreams_query(tag)
      |> Repo.all()
      |> Enum.each(fn dream ->
        assert dream.id in Enum.map(tagged_dreams, & &1.id)
      end)
    end
  end

  describe "published_dreams" do
    test "公開済みの夢のうち、他者の非公開を除く夢を返すクエリを返す", %{user: user} do
      Dreams.published_dreams(Dream, user)
      |> Repo.all()
      |> Enum.each(fn dream ->
        refute dream.draft
        refute dream.secret and dream.user_id != user.id
      end)
    end
  end

  describe "without_reported_dreams()" do
    setup [:report_dream]

    test "自分が通報した夢以外を返すクエリを返す", %{user: user, tags: [tag | _], reported_dreams: [reported_dream | _]} do
      Dream
      |> Dreams.without_reported_dreams(user)
      |> Repo.all()
      |> Enum.each(fn dream ->
        assert dream.id != reported_dream.id
      end)

      tag
      |> Dreams.dreams_query()
      |> Dreams.without_reported_dreams(user)
      |> Repo.all()
      |> Enum.each(fn dream ->
        assert dream.id != reported_dream.id
      end)
    end
  end

  describe "get_dream!" do
    test "IDをもとに夢を返す", %{user: user, dreams: [dream | _]} do
      assert Dreams.get_dream!(user, dream.id) |> Map.get(:id) == dream.id
    end
  end

  describe "create_dream" do
    test "夢をつくる", %{user: user, tags: tags} do
      tag_names = Enum.map(tags, & &1.name) |> Enum.sort()
      dream_attrs = Fixture.Dreams.dream(%{"tags" => tag_names})
      {:ok, %{dream: dream}} = Dreams.create_dream(user, dream_attrs)

      assert dream.body == dream_attrs["body"]
      assert dream.date == dream_attrs["date"]
      assert dream.draft == dream_attrs["draft"]
      assert dream.secret == dream_attrs["secret"]
      assert dream.tags |> Enum.map(& &1.name) |> Enum.sort() == tag_names
    end

    test "パラメータがよくないときはエラーを返す", %{user: user} do
      assert {:error, :dream, %Ecto.Changeset{}, _} = Dreams.create_dream(user, %{"body" => ""})
    end

    test "タグがないときはつくる", %{user: user} do
      dream_attrs = Fixture.Dreams.dream(%{"tags" => ["foooo"]})
      {:ok, %{dream: %Dream{tags: [tag]}}} = Dreams.create_dream(user, dream_attrs)

      assert tag.name == "foooo"
      assert Tag |> where(name: "foooo") |> Repo.one()
    end
  end

  describe "update_dream" do
    test "夢を更新する", %{dreams: [dream | _]} do
      dream_attrs = Fixture.Dreams.dream(%{"tags" => ["ハッピー"]})
      {:ok, %{dream: dream}} = Dreams.update_dream(dream, dream_attrs)

      assert dream.body == dream_attrs["body"]
      assert dream.date == dream_attrs["date"]
      assert dream.draft == dream_attrs["draft"]
      assert dream.secret == dream_attrs["secret"]
    end

    test "パラメータがよくないときはエラーを返す", %{user: user, dreams: [dream | _]} do
      assert {:error, :dream, %Ecto.Changeset{}, _} = Dreams.update_dream(dream, %{"body" => ""})
      assert Dreams.get_dream!(user, dream.id) |> Map.get(:body) == dream.body
    end

    test "タグを差し替える", %{dreams: [dream | _], tags: [_tag, tag]} do
      {:ok, %{dream: %Dream{tags: [new_tag]}}} = Dreams.update_dream(dream, %{"tags" => [tag.name]})

      assert new_tag.name == tag.name
    end

    test "タグを外せる", %{dreams: [dream | _]} do
      {:ok, %{dream: dream}} = Dreams.update_dream(dream, %{"tags" => []})

      assert dream.tags == []
    end

    test "タグがないときはつくる", %{dreams: [dream | _]} do
      refute Tag |> where(name: "foooo") |> Repo.one()

      dream_attrs = Fixture.Dreams.dream(%{"tags" => ["foooo"]})
      {:ok, %{dream: %Dream{tags: [tag]}}} = Dreams.update_dream(dream, dream_attrs)

      assert tag.name == "foooo"
      assert Tag |> where(name: "foooo") |> Repo.one()
    end
  end

  describe "delete_dream" do
    test "夢を消す", %{user: user, dreams: [dream | _]} do
      assert {:ok, %Dream{}} = Dreams.delete_dream(dream)

      assert_raise Ecto.NoResultsError, fn ->
        Dreams.get_dream!(user, dream.id)
      end
    end

    test "タグは消さない", %{dreams: [dream = %{tags: tags} | _]} do
      assert {:ok, %Dream{}} = Dreams.delete_dream(dream)

      Enum.each(tags, fn tag ->
        assert Tag |> where(name: ^tag.name) |> Repo.one()
      end)
    end
  end

  describe "report_dream" do
    test "他人の夢を通報できる", %{user: user, dreams: [_, dream | _]} do
      {:ok, report} = Dreams.report_dream(user, dream)

      assert report.user_id == user.id
      assert report.dream_id == dream.id
    end

    test "何度通報してもReportは1つしかつくらない", %{user: user, dreams: [_, dream | _]} do
      count = Repo.aggregate(Report, :count, :id)

      {:ok, _} = Dreams.report_dream(user, dream)
      {:ok, _} = Dreams.report_dream(user, dream)
      {:ok, _} = Dreams.report_dream(user, dream)

      assert Repo.aggregate(Report, :count, :id) == count + 1
    end

    test "自分の夢は通報できない", %{user: user, dreams: [dream | _]} do
      assert {:error, changeset} = Dreams.report_dream(user, dream)
    end
  end

  describe "search_tags_query" do
    setup do
      Dreams.create_tags(~w[nightmare happy 留年])
      :ok
    end

    test "曖昧なタグの検索ができる" do
      [tag] = Dreams.search_tags_query(Tag, "nighm") |> Repo.all

      assert tag.name == "nightmare"
    end
  end

  defp create_user(_) do
    {:ok, %{user: user}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())

    %{user: user, another: another}
  end

  defp create_dreams(%{user: user, another: another}) do
    {:ok, tags = [tag | _]} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])
    {:ok, %{dream: d1}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"tags" => [tag.name]}))
    {:ok, %{dream: d2}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"tags" => [tag.name]}))
    {:ok, %{dream: d3}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))
    {:ok, %{dream: d4}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"draft" => true, "secret" => false}))
    {:ok, %{dream: d5}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"draft" => false, "secret" => true}))
    {:ok, %{dream: d6}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"draft" => true, "secret" => true}))
    {:ok, %{dream: d7}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))
    {:ok, %{dream: d8}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => true, "secret" => false}))
    {:ok, %{dream: d9}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => false, "secret" => true}))
    {:ok, %{dream: d10}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => true, "secret" => true}))

    %{dreams: [d1, d2, d3, d4, d5, d6, d7, d8, d9, d10], tags: tags}
  end

  defp report_dream(%{user: user, another: another, dreams: [user_dream, another_dream | _]}) do
    {:ok, reported_another_dream} = Dreams.report_dream(user, another_dream)
    {:ok, reported_user_dream} = Dreams.report_dream(another, user_dream)

    %{reported_dreams: [reported_another_dream, reported_user_dream]}
  end
end
