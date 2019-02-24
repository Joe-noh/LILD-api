defmodule LILD.Accounts.FirebaseAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "firebase_accounts" do
    field :firebase_uid, :string
    field :provider_uid, :string
    field :provider, :string

    belongs_to :user, LILD.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(firebase_account, attrs) do
    firebase_account
    |> cast(attrs, [:firebase_uid, :provider_uid, :provider])
    |> validate_required([:firebase_uid, :provider_uid, :provider])
  end
end
