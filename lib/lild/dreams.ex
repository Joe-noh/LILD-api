defmodule LILD.Dreams do
  @moduledoc """
  The Dreams context.
  """

  import Ecto.Query, warn: false

  alias LILD.Repo
  alias LILD.Dreams.Dream
  alias LILD.Accounts.User

  def list_dreams do
    Repo.all(Dream)
  end

  def get_dream!(id), do: Repo.get!(Dream, id)

  def create_dream(user = %User{}, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:dreams)
    |> Dream.changeset(attrs)
    |> Repo.insert()
  end

  def update_dream(dream = %Dream{}, attrs) do
    dream
    |> Dream.changeset(attrs)
    |> Repo.update()
  end

  def delete_dream(dream = %Dream{}) do
    Repo.delete(dream)
  end
end
