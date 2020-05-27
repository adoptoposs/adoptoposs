defmodule Adoptoposs.Repo.Migrations.AddStatusToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :status, :string, default: "published", null: false
    end

    create index(:projects, :status)
  end
end
