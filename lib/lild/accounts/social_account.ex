defmodule LILD.Accounts.SocialAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "social_accounts" do
    field :uid, :string
    field :provider, :string

    belongs_to :user, LILD.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(social_account, attrs) do
    social_account
    |> cast(attrs, [:uid, :provider])
    |> validate_required([:uid, :provider])
    |> unique_constraint(:uid, name: :social_accounts_provider_uid_index)
  end
end
