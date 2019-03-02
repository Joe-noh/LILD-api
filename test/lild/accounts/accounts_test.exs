defmodule LILD.AccountsTest do
  use LILD.DataCase, async: true

  alias LILD.Accounts

  describe "users" do
    setup [:create_user]

    test "get_user!/1 returns the user with given id", %{user: user} do
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      user_attrs = Fixture.Accounts.user()
      firebase_account_attrs = Fixture.Accounts.firebase_account()
      {:ok, %{user: user, firebase_account: firebase_account}} = Accounts.create_user(user_attrs, firebase_account_attrs)

      assert user.name == user_attrs["name"]
      assert user.avatar_url == user_attrs["avatar_url"]
      assert firebase_account.firebase_uid == firebase_account_attrs["firebase_uid"]
      assert firebase_account.provider_uid == firebase_account_attrs["provider_uid"]
      assert firebase_account.provider == firebase_account_attrs["provider"]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, _, %Ecto.Changeset{}, _} = Accounts.create_user(%{}, %{})
    end

    test "update_user/2 with valid data updates the user", %{user: user} do
      update_attrs = Fixture.Accounts.user()

      assert {:ok, user} = Accounts.update_user(user, update_attrs)
      assert user.name == update_attrs["name"]
      assert user.avatar_url == update_attrs["avatar_url"]
    end

    test "update_user/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, %{name: ''})
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user", %{user: user} do
      assert {:ok, %{user: _, firebase_account: _}} = Accounts.delete_user(user)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(user.id)
      end
    end
  end

  defp create_user(_) do
    Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())
  end
end
