defmodule Adoptoposs.Repo.Migrations.CreateSearchIndexes do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION pg_trgm"

    execute "CREATE INDEX projects_language_trgm_index ON projects USING gin (language gin_trgm_ops)"
    execute "CREATE INDEX projects_name_trgm_index ON projects USING gin (name gin_trgm_ops)"
    drop index(:projects, [:name])
    drop index(:projects, [:language])
  end

  def down do
    create index(:projects, [:name])
    create index(:projects, [:language])
    execute "DROP INDEX projects_name_trgm_index"
    execute "DROP INDEX projects_language_trgm_index"

    execute "DROP EXTENSION pg_trgm"
  end
end
