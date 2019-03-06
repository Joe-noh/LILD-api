defmodule LILD.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias LILD.Accounts.SocialAccount
  alias LILD.Dreams.{Dream, Report}

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "users" do
    field :avatar_url, :string
    field :name, :string

    has_one :twitter_account, SocialAccount, where: [provider: "twitter.com"]
    has_one :google_account, SocialAccount, where: [provider: "google.com"]
    has_many :social_accounts, SocialAccount
    has_many :dreams, Dream
    has_many :reports, Report

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
