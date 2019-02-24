defmodule LILD.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias LILD.Repo
  alias LILD.Accounts.{User, FirebaseAccount}

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def create_user(user_attrs, firebase_account_attrs) do
    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, user_attrs))
    |> Multi.run(:firebase_account, fn repo, %{user: user} ->
      user
      |> Ecto.build_assoc(:firebase_account)
      |> FirebaseAccount.changeset(firebase_account_attrs)
      |> repo.insert
    end)
    |> Repo.transaction()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def verify_id_token(id_token) do
    Jwt.verify(id_token)
  end
end
