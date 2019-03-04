defmodule LILD.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias LILD.Accounts

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "users" do
    field :avatar_url, :string
    field :name, :string

    has_one :twitter_account, Accounts.SocialAccount, where: [provider: "twitter.com"]
    has_one :google_account, Accounts.SocialAccount, where: [provider: "google.com"]
    has_many :dreams, LILD.Dreams.Dream

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :avatar_url])
    |> validate_required([:name, :avatar_url])
  end

  def build_social_account(user, %{"provider" => "twitter.com"}) do
    user |> Ecto.build_assoc(:twitter_account)
  end

  def build_social_account(user, %{"provider" => "google.com"}) do
    user |> Ecto.build_assoc(:google_account)
  end
end
