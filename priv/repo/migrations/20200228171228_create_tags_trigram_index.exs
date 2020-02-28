defmodule Adoptoposs.Repo.Migrations.CreateTagsTrigramIndex do
  use Ecto.Migration

  def up do
    execute "CREATE INDEX tags_name_trgm_index ON tags USING gin (name gin_trgm_ops)"
  end

  def down do
    execute "DROP INDEX tags_name_trgm_index"
  end
end
