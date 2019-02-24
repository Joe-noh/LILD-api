defmodule LILD.Repo.Migrations.CreateFirebaseAccounts do
  use Ecto.Migration

  def change do
    create table(:firebase_accounts, primary_key: false) do
      add :id, :binary_id, null: false, primary_key: true
      add :firebase_uid, :string, null: false
      add :provider_uid, :string, null: false
      add :provider, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:firebase_accounts, [:user_id])
  end
end
