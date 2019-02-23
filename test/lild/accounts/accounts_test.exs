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

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
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

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "firebase_accounts" do
    alias LILD.Accounts.FirebaseAccount

    @valid_attrs %{provider: "some provider", uid: "some uid"}
    @update_attrs %{provider: "some updated provider", uid: "some updated uid"}
    @invalid_attrs %{provider: nil, uid: nil}

    def firebase_account_fixture(attrs \\ %{}) do
      {:ok, firebase_account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_firebase_account()

      firebase_account
    end

    test "list_firebase_accounts/0 returns all firebase_accounts" do
      firebase_account = firebase_account_fixture()
      assert Accounts.list_firebase_accounts() == [firebase_account]
    end

    test "get_firebase_account!/1 returns the firebase_account with given id" do
      firebase_account = firebase_account_fixture()
      assert Accounts.get_firebase_account!(firebase_account.id) == firebase_account
    end

    test "create_firebase_account/1 with valid data creates a firebase_account" do
      assert {:ok, %FirebaseAccount{} = firebase_account} = Accounts.create_firebase_account(@valid_attrs)
      assert firebase_account.provider == "some provider"
      assert firebase_account.uid == "some uid"
    end

    test "create_firebase_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_firebase_account(@invalid_attrs)
    end

    test "update_firebase_account/2 with valid data updates the firebase_account" do
      firebase_account = firebase_account_fixture()
      assert {:ok, %FirebaseAccount{} = firebase_account} = Accounts.update_firebase_account(firebase_account, @update_attrs)
      assert firebase_account.provider == "some updated provider"
      assert firebase_account.uid == "some updated uid"
    end

    test "update_firebase_account/2 with invalid data returns error changeset" do
      firebase_account = firebase_account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_firebase_account(firebase_account, @invalid_attrs)
      assert firebase_account == Accounts.get_firebase_account!(firebase_account.id)
    end

    test "delete_firebase_account/1 deletes the firebase_account" do
      firebase_account = firebase_account_fixture()
      assert {:ok, %FirebaseAccount{}} = Accounts.delete_firebase_account(firebase_account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_firebase_account!(firebase_account.id) end
    end

    test "change_firebase_account/1 returns a firebase_account changeset" do
      firebase_account = firebase_account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_firebase_account(firebase_account)
    end
  end
end
