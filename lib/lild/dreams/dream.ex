defmodule LILD.Dreams.Dream do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "dreams" do
    field :body, :string
    field :date, :date
    field :draft, :boolean, default: false
    field :secret, :boolean, default: false

    belongs_to :user, LILD.Accounts.User
    many_to_many :tags, LILD.Dreams.Tag, join_through: "dreams_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(dream, attrs) do
    dream
    |> cast(attrs, [:body, :date, :secret, :draft])
    |> validate_required([:body, :date, :secret, :draft])
  end
end
