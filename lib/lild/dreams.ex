defmodule LILD.Dreams do
  @moduledoc """
  The Dreams context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
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
    Multi.new()
    |> Multi.run(:tags, fn repo, _ ->
      attrs
      |> Map.get("tags", [])
      |> create_tags(repo)
    end)
    |> Multi.run(:dream, fn repo, %{tags: tags} ->
      user
      |> Ecto.build_assoc(:dreams)
      |> Dream.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:tags, tags)
      |> repo.insert()
    end)
    |> Repo.transaction()
  end

  def update_dream(dream = %Dream{}, attrs) do
    dream = Repo.preload(dream, :tags)

    Multi.new()
    |> Multi.run(:tags, fn repo, _ ->
      attrs
      |> Map.get("tags", [])
      |> create_tags(repo)
    end)
    |> Multi.run(:dream, fn repo, %{tags: tags} ->
      dream
      |> Repo.preload(:tags)
      |> Dream.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:tags, tags)
      |> repo.update()
    end)
    |> Repo.transaction()
  end

  def delete_dream(dream = %Dream{}) do
    Repo.delete(dream)
  end

  def list_tags do
    Repo.all(Tag)
  end

  def create_tags(names, repo \\ Repo) do
    names
    |> Enum.map(& Tag.changeset(%Tag{}, %{name: &1}))
    |> Enum.map(& repo.insert(&1, on_conflict: :nothing))
    |> Enum.filter(& match?({:ok, _}, &1))
    |> Enum.map(fn {:ok, tag} -> tag.name end)
    |> get_tags_by_name(repo)
  end

  defp get_tags_by_name(names, repo) do
    tags = Tag |> where([t], t.name in ^names) |> repo.all()

    {:ok, tags}
  end
end
