defmodule LILD.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias LILD.Repo

  alias LILD.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias LILD.Accounts.FirebaseAccount

  @doc """
  Returns the list of firebase_accounts.

  ## Examples

      iex> list_firebase_accounts()
      [%FirebaseAccount{}, ...]

  """
  def list_firebase_accounts do
    Repo.all(FirebaseAccount)
  end

  @doc """
  Gets a single firebase_account.

  Raises `Ecto.NoResultsError` if the Firebase account does not exist.

  ## Examples

      iex> get_firebase_account!(123)
      %FirebaseAccount{}

      iex> get_firebase_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_firebase_account!(id), do: Repo.get!(FirebaseAccount, id)

  @doc """
  Creates a firebase_account.

  ## Examples

      iex> create_firebase_account(%{field: value})
      {:ok, %FirebaseAccount{}}

      iex> create_firebase_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_firebase_account(attrs \\ %{}) do
    %FirebaseAccount{}
    |> FirebaseAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a firebase_account.

  ## Examples

      iex> update_firebase_account(firebase_account, %{field: new_value})
      {:ok, %FirebaseAccount{}}

      iex> update_firebase_account(firebase_account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_firebase_account(%FirebaseAccount{} = firebase_account, attrs) do
    firebase_account
    |> FirebaseAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a FirebaseAccount.

  ## Examples

      iex> delete_firebase_account(firebase_account)
      {:ok, %FirebaseAccount{}}

      iex> delete_firebase_account(firebase_account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_firebase_account(%FirebaseAccount{} = firebase_account) do
    Repo.delete(firebase_account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking firebase_account changes.

  ## Examples

      iex> change_firebase_account(firebase_account)
      %Ecto.Changeset{source: %FirebaseAccount{}}

  """
  def change_firebase_account(%FirebaseAccount{} = firebase_account) do
    FirebaseAccount.changeset(firebase_account, %{})
  end
end
