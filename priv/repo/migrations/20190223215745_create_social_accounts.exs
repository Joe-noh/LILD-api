defmodule LILD.Repo.Migrations.CreateSocialAccounts do
  use Ecto.Migration

  def change do
    create table(:social_accounts, primary_key: false) do
      add :id, :binary_id, null: false, primary_key: true
      add :uid, :string, null: false
      add :provider, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:social_accounts, [:user_id])
    create unique_index(:social_accounts, [:provider, :uid])
  end
end
