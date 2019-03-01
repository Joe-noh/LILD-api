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
      names =
        (Map.get(attrs, "tags") || Map.get(attrs, :tags, []))
        |> Enum.map(fn
          %{name: name} -> name
          %{"name" => name} -> name
        end)

      try do
        {:ok, create_tags!(names, repo)}
      rescue
        e in Ecto.InvalidChangesetError ->
          {:error, e.changeset}
      end
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
    tags = Map.get(attrs, "tags") || Map.get(attrs, :tags)

    if tags do
      tag_names = Enum.map(tags, fn
        %{name: name} -> name
        %{"name" => name} -> name
      end)

      update_dream_with_tags(dream, attrs, tag_names)
    else
      do_update_dream(dream, attrs)
    end
  end

  defp update_dream_with_tags(dream = %Dream{}, attrs, tag_names) do
    Multi.new()
    |> Multi.run(:tags, fn repo, _ ->
      try do
        {:ok, create_tags!(tag_names, repo)}
      rescue
        e in Ecto.InvalidChangesetError ->
          {:error, e.changeset}
      end
    end)
    |> Multi.run(:dream, fn repo, %{tags: tags} ->
      dream
      |> repo.preload(:tags)
      |> Dream.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:tags, tags)
      |> repo.update()
    end)
    |> Repo.transaction()
  end

  defp do_update_dream(dream = %Dream{}, attrs) do
    changeset = Dream.changeset(dream, attrs)

    Multi.new()
    |> Multi.update(:dream, changeset)
    |> Repo.transaction()
  end

  def delete_dream(dream = %Dream{}) do
    Repo.delete(dream)
  end

  def list_tags do
    Repo.all(Tag)
  end

  def create_tags!(names, repo \\ Repo) do
    names_in_db =
      names
      |> Enum.map(&Tag.changeset(%Tag{}, %{name: &1}))
      |> Enum.map(&repo.insert!(&1, on_conflict: :nothing))
      |> Enum.map(& &1.name)

    Tag |> where([t], t.name in ^names_in_db) |> repo.all()
  end
end
