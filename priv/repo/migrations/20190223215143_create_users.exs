defmodule LILD.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, null: false, primary_key: true
      add :name, :string, null: false
      add :avatar_url, :string, null: false

      timestamps()
    end
  end
end
