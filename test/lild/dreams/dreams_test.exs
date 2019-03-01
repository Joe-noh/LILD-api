defmodule LILD.DreamsTest do
  use LILD.DataCase, async: true

  alias LILD.{Dreams, Accounts}
  alias LILD.Dreams.Dream

  describe "dreams" do
    setup [:create_user, :create_dream]

    test "list_dreams/0 returns all dreams", %{dream: dream} do
      assert Dreams.list_dreams() |> Enum.map(& &1.id) == [dream.id]
    end

    test "get_dream!/1 returns the dream with given id", %{user: user, dream: dream} do
      assert Dreams.get_dream!(user, dream.id) |> Map.get(:id) == dream.id
    end

    test "create_dream/1 with valid data creates a dream", %{user: user} do
      dream_attrs = Fixture.Dreams.dream()
      {:ok, %{dream: dream}} = Dreams.create_dream(user, dream_attrs)

      assert dream.body == dream_attrs.body
      assert dream.date == dream_attrs.date
      assert dream.draft == dream_attrs.draft
      assert dream.secret == dream_attrs.secret
      assert dream.tags |> Enum.map(& &1.name) |> Enum.sort() == dream_attrs.tags |> Enum.uniq() |> Enum.sort()
    end

    test "create_dream/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, :dream, %Ecto.Changeset{}, _} = Dreams.create_dream(user, %{body: ""})
    end

    test "create_dream/1 with invalid tag name returns error changeset", %{user: user} do
      assert {:error, :tags, %Ecto.Changeset{}, _} = Dreams.create_dream(user, %{tags: ["whitespace included"]})
    end

    test "update_dream/2 with valid data updates the dream", %{dream: dream} do
      dream_attrs = Fixture.Dreams.dream()
      {:ok, dream} = Dreams.update_dream(dream, dream_attrs)

      assert dream.body == dream_attrs.body
      assert dream.date == dream_attrs.date
      assert dream.draft == dream_attrs.draft
      assert dream.secret == dream_attrs.secret
    end

    test "update_dream/2 with invalid data returns error changeset", %{user: user, dream: dream} do
      assert {:error, %Ecto.Changeset{}} = Dreams.update_dream(dream, %{body: ''})
      assert Dreams.get_dream!(user, dream.id) |> Map.get(:body) == dream.body
    end

    test "delete_dream/1 deletes the dream", %{user: user, dream: dream} do
      assert {:ok, %Dream{}} = Dreams.delete_dream(dream)

      assert_raise Ecto.NoResultsError, fn ->
        Dreams.get_dream!(user, dream.id)
      end
    end
  end

  describe "tags" do
    test "create same tag multiple times" do
      assert Dreams.create_tags!(~w[a a a]) |> length == 1
      assert Dreams.create_tags!(~w[a a a]) |> length == 1
    end
  end

  defp create_user(_) do
    Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())
  end

  defp create_dream(%{user: user}) do
    Dreams.create_dream(user, Fixture.Dreams.dream())
  end
end
