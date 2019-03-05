defmodule LILD.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias LILD.Repo
  alias LILD.Accounts.{User, SocialAccount}

  defdelegate preload(struct, assoc), to: Repo

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user_by_social_account(provider, uid) do
    User
    |> join(:inner, [u], s in assoc(u, :social_accounts))
    |> where([u, s], s.provider == ^provider and s.uid == ^uid)
    |> Repo.one()
  end

  def create_user(user_attrs, social_account_attrs) do
    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, user_attrs))
    |> Multi.run(:social_account, fn repo, %{user: user} ->
      user
      |> User.build_social_account(social_account_attrs)
      |> SocialAccount.changeset(social_account_attrs)
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
    with {:ok, %{"firebase" => payload}} <- Jwt.verify(id_token) do
      %{"sign_in_provider" => provider, "identities" => identities} = payload
      [uid] = Map.get(identities, provider)

      {:ok, %{"uid" => uid, "provider" => provider}}
    end
  end
end
