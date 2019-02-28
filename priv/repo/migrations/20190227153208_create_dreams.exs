defmodule LILD.Repo.Migrations.CreateDreams do
  use Ecto.Migration

  def change do
    create table(:dreams, primary_key: false) do
      add :id, :binary_id, null: false, primary_key: true
      add :body, :text, null: false
      add :date, :date, null: false
      add :secret, :boolean, default: false, null: false
      add :draft, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:dreams, [:user_id])
    create index(:dreams, [:date])
  end
end
