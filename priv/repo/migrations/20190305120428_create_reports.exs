defmodule LILD.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports, primary_key: false) do
      add :id, :binary_id, null: false, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :dream_id, references(:dreams, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:reports, [:user_id])
    create index(:reports, [:dream_id])
    create unique_index(:reports, [:user_id, :dream_id])
  end
end
