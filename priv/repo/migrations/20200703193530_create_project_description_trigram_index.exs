defmodule Adoptoposs.Repo.Migrations.CreateProjectDescriptionTrigramIndex do
  use Ecto.Migration

  def up do
    execute "CREATE INDEX project_description_trgm_index ON projects USING gin (description gin_trgm_ops)"
  end

  def down do
    execute "DROP INDEX project_description_trgm_index"
  end
end
