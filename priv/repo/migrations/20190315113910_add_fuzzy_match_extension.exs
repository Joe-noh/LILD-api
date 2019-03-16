defmodule LILD.Repo.Migrations.AddFuzzyMatchExtension do
  use Ecto.Migration

  def up do
    execute "CREATE extension if not exists fuzzystrmatch;"
    execute "CREATE extension if not exists pg_trgm;"
    execute "CREATE INDEX tags_name_trgm_index ON tags USING gin (name gin_trgm_ops);"
  end

  def down do
    execute "DROP INDEX tags_name_trgm_index;"
    execute "DROP extension if exists pg_trgm;"
    execute "DROP extension if exists fuzzystrmatch;"
  end
end
