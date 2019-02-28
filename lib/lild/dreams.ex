defmodule LILD.Dreams do
  @moduledoc """
  The Dreams context.
  """

  import Ecto.Query, warn: false

  alias LILD.Repo
  alias LILD.Dreams.{Dream, Tag}
  alias LILD.Accounts.User

  def list_dreams do
    Dream |> list_dreams()
  end

  def list_dreams(user = %User{}) do
    user
    |> Ecto.assoc(:dreams)
    |> list_dreams()
  end

  def list_dreams(queryable) do
    queryable
    |> order_by([d], desc: [d.date, d.inserted_at])
    |> Repo.all()
  end

  def get_dream!(user = %User{}, id) do
    user
    |> Ecto.assoc(:dreams)
    |> Repo.get!(id)
  end

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

  def list_tags do
    Repo.all(Tag)
  end

  def create_tags!(names) do
    names_in_db =
      names
      |> Enum.map(&Tag.changeset(%Tag{}, %{name: &1}))
      |> Enum.map(&Repo.insert!(&1, on_conflict: :nothing))
      |> Enum.map(& &1.name)

    Tag |> where([t], t.name in ^names_in_db) |> Repo.all()
  end
end
