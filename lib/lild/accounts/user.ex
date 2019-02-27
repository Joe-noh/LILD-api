defmodule LILD.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "users" do
    field :avatar_url, :string
    field :name, :string

    has_one :firebase_account, LILD.Accounts.FirebaseAccount
    has_many :dreams, LILD.Dreams.Dream

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :avatar_url])
    |> validate_required([:name, :avatar_url])
  end
end
