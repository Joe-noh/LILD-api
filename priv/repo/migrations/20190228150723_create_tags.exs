defmodule LILD.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :id, :binary_id, null: false, primary_key: true
      add :name, :string, null: false

      timestamps()
    end

    create table(:dreams_tags, primary_key: false) do
      add :dream_id, references(:dreams, on_delete: :nothing, type: :binary_id)
      add :tag_id, references(:tags, on_delete: :nothing, type: :binary_id)
    end

    create unique_index(:tags, [:name])
  end
end
