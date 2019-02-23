defmodule LILD.AccountsTest do
  use LILD.DataCase

  alias LILD.Repo
  alias LILD.Accounts

  describe "users" do
    alias LILD.Accounts.User
    alias LILD.Accounts.FirebaseAccount

    @valid_attrs %{avatar_url: "some avatar_url", name: "some name"}
    @update_attrs %{avatar_url: "some updated avatar_url", name: "some updated name"}
    @invalid_attrs %{avatar_url: nil, name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "user and firebase_account" do
      user = user_fixture()

      user
      |> Ecto.build_assoc(:firebase_account)
      |> FirebaseAccount.changeset(%{provider: "some provider", uid: "some uid"})
      |> IO.inspect
      |> Repo.insert!
      |> Ecto.assoc(:user)
      |> Repo.one
      |> IO.inspect
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.avatar_url == "some avatar_url"
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.avatar_url == "some updated avatar_url"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end
  end
end
