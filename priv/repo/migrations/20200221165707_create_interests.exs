defmodule Adoptoposs.Repo.Migrations.CreateInterests do
  use Ecto.Migration

  def change do
    create table(:interests) do
      add :creator_id, references(:users, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps()
    end

    create index(:interests, [:creator_id])
    create index(:interests, [:project_id])
    create unique_index(:interests, [:creator_id, :project_id])
  end
end
