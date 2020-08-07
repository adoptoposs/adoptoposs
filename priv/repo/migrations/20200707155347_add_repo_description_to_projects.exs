defmodule Adoptoposs.Repo.Migrations.AddRepoDescriptionToProjects do
  use Ecto.Migration

  alias Adoptoposs.Repo
  import Ecto.Query, only: [from: 2]

  def up do
    alter table(:projects) do
      add :repo_description, :string
    end

    # ensure the new column is added
    flush()

    # Copy over the repo description values
    from(
      p in "projects",
      update: [set: [repo_description: p.data["description"]]]
    )
    |> Repo.update_all([])

    execute "CREATE INDEX project_repo_description_trgm_index ON projects USING gin (repo_description gin_trgm_ops)"
  end

  def down do
    execute "DROP INDEX project_repo_description_trgm_index"

    alter table(:projects) do
      remove :repo_description
    end
  end
end
