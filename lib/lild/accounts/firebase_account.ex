defmodule LILD.Accounts.FirebaseAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "firebase_accounts" do
    field :provider, :string
    field :uid, :string

    belongs_to :user, LILD.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(firebase_account, attrs) do
    firebase_account
    |> cast(attrs, [:uid, :provider])
    |> validate_required([:uid, :provider])
  end
end
