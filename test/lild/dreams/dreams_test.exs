defmodule LILD.DreamsTest do
  use LILD.DataCase, async: true

  alias LILD.{Dreams, Accounts}
  alias LILD.Dreams.{Dream, Tag}

  describe "dreams_query" do
    setup [:create_user, :create_dreams]

    test "夢をすべて返すクエリを返す", %{dreams: dreams} do
      Dreams.dreams_query()
      |> Repo.all()
      |> Enum.each(fn dream ->
        assert dream.id in Enum.map(dreams, & &1.id)
      end)
    end

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
    setup [:create_user, :create_dreams]

    test "下書きでも非公開でもない夢を返すクエリを返す", %{user: user} do
      user
      |> Ecto.assoc(:dreams)
      |> Dreams.published_dreams()
      |> Repo.all()
      |> Enum.each(fn dream ->
        refute dream.draft
        refute dream.secret
      end)
    end
  end

  describe "get_dream!" do
    setup [:create_user, :create_dreams]

    test "IDをもとに夢を返す", %{user: user, dreams: [dream | _]} do
      assert Dreams.get_dream!(user, dream.id) |> Map.get(:id) == dream.id
    end
  end

  describe "create_dream" do
    setup [:create_user, :create_dreams]

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
    setup [:create_user, :create_dreams]

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
    setup [:create_user, :create_dreams]

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

  defp create_user(_) do
    {:ok, %{user: user}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())

    %{user: user, another: another}
  end

  defp create_dreams(%{user: user, another: another}) do
    {:ok, tags = [tag | _]} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])
    {:ok, %{dream: dream1}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"tags" => [tag.name]}))
    {:ok, %{dream: dream2}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"tags" => [tag.name]}))
    {:ok, %{dream: dream3}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))

    %{dreams: [dream1, dream2, dream3], tags: tags}
  end
end
