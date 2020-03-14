defmodule Adoptoposs.Repo.Migrations.AddRepoOwnerToProjects do
  use Ecto.Migration

  def up do
    alter table(:projects) do
      add :repo_owner, :string, default: ""
    end

    execute "CREATE INDEX projects_repo_owner_trgm_index ON projects USING gin (repo_owner gin_trgm_ops)"
  end

  def down do
    execute "DROP INDEX projects_repo_owner_trgm_index"

    alter table(:projects) do
      remove(:repo_owner)
    end
  end
end
