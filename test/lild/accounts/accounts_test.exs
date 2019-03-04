defmodule LILD.AccountsTest do
  use LILD.DataCase, async: true

  alias LILD.Accounts

  describe "get_user!" do
    setup [:create_user]

    test "get_user!/1 returns the user with given id", %{user: user} do
      assert Accounts.get_user!(user.id) == user
    end
  end

  describe "create_user" do
    setup [:create_user]

    test "create_user/1 with valid data creates a user" do
      user_attrs = Fixture.Accounts.user()
      social_account_attrs = Fixture.Accounts.social_account()
      {:ok, %{user: user, social_account: social_account}} = Accounts.create_user(user_attrs, social_account_attrs)

      assert user.name == user_attrs["name"]
      assert user.avatar_url == user_attrs["avatar_url"]
      assert social_account.uid == social_account_attrs["uid"]
      assert social_account.provider == social_account_attrs["provider"]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, _, %Ecto.Changeset{}, _} = Accounts.create_user(%{}, %{})
    end
  end

  describe "update_user" do
    setup [:create_user]

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
  end

  describe "delete_user" do
    setup [:create_user]

    test "delete_user/1 deletes the user", %{user: user} do
      assert {:ok, _user} = Accounts.delete_user(user)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(user.id)
      end
    end
  end

  defp create_user(_) do
    Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
  end
end
