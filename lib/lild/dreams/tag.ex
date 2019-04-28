defmodule LILD.Dreams.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "tags" do
    field :name, :string

    many_to_many :dreams, LILD.Dreams.Dream, join_through: "dreams_tags"

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> remove_chars(~r/[\s#]+/)
    |> validate_format(:name, ~r/\A[^\s]+\z/)
    |> unique_constraint(:name, name: :tags_name_index)
  end

  defp remove_chars(changeset, regex) do
    case get_change(changeset, :name) do
      nil -> changeset
      name -> put_change(changeset, :name, Regex.replace(regex, name, "", global: true))
    end
  end
end
