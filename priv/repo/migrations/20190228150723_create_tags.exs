defmodule LILD.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :id, :binary_id, null: false, primary_key: true
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:tags, [:name], name: :tags_name_index)

    create table(:dreams_tags, primary_key: false) do
      add :dream_id, references(:dreams, on_delete: :delete_all, type: :binary_id), null: false
      add :tag_id, references(:tags, on_delete: :delete_all, type: :binary_id), null: false
    end
  end
end
