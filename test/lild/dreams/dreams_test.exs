defmodule LILD.DreamsTest do
  use LILD.DataCase, async: true

  alias LILD.{Dreams, Accounts}
  alias LILD.Dreams.{Dream, Tag}

  describe "dreams_query" do
    setup [:create_user, :create_dream]

    test "夢をすべて返すクエリを返す", %{dream: dream} do
      assert Dreams.dreams_query() |> Repo.all() |> Enum.map(& &1.id) == [dream.id]
    end
  end

  describe "get_dream!" do
    setup [:create_user, :create_dream]

    test "IDをもとに夢を返す", %{user: user, dream: dream} do
      assert Dreams.get_dream!(user, dream.id) |> Map.get(:id) == dream.id
    end
  end

  describe "create_dream" do
    setup [:create_user, :create_dream]

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
    setup [:create_user, :create_dream]

    test "夢を更新する", %{dream: dream} do
      dream_attrs = Fixture.Dreams.dream(%{"tags" => ["ハッピー"]})
      {:ok, %{dream: dream}} = Dreams.update_dream(dream, dream_attrs)

      assert dream.body == dream_attrs["body"]
      assert dream.date == dream_attrs["date"]
      assert dream.draft == dream_attrs["draft"]
      assert dream.secret == dream_attrs["secret"]
    end

    test "パラメータがよくないときはエラーを返す", %{user: user, dream: dream} do
      assert {:error, :dream, %Ecto.Changeset{}, _} = Dreams.update_dream(dream, %{"body" => ""})
      assert Dreams.get_dream!(user, dream.id) |> Map.get(:body) == dream.body
    end

    test "タグを差し替える", %{dream: dream, tags: [_tag, tag]} do
      {:ok, %{dream: %Dream{tags: [new_tag]}}} = Dreams.update_dream(dream, %{"tags" => [tag.name]})

      assert new_tag.name == tag.name
    end

    test "タグを外せる", %{dream: dream} do
      {:ok, %{dream: dream}} = Dreams.update_dream(dream, %{"tags" => []})

      assert dream.tags == []
    end

    test "タグがないときはつくる", %{dream: dream} do
      refute Tag |> where(name: "foooo") |> Repo.one()

      dream_attrs = Fixture.Dreams.dream(%{"tags" => ["foooo"]})
      {:ok, %{dream: %Dream{tags: [tag]}}} = Dreams.update_dream(dream, dream_attrs)

      assert tag.name == "foooo"
      assert Tag |> where(name: "foooo") |> Repo.one()
    end
  end

  describe "delete_dream" do
    setup [:create_user, :create_dream]

    test "夢を消す", %{user: user, dream: dream} do
      assert {:ok, %Dream{}} = Dreams.delete_dream(dream)

      assert_raise Ecto.NoResultsError, fn ->
        Dreams.get_dream!(user, dream.id)
      end
    end

    test "タグは消さない", %{dream: dream} do
      tags = dream.tags

      assert {:ok, %Dream{}} = Dreams.delete_dream(dream)

      Enum.each(tags, fn tag ->
        assert Tag |> where(name: ^tag.name) |> Repo.one()
      end)
    end
  end

  defp create_user(_) do
    Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())
  end

  defp create_dream(%{user: user}) do
    {:ok, tags = [tag | _]} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])
    {:ok, %{dream: dream}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"tags" => [tag.name]}))

    %{dream: dream, tags: tags}
  end
end
