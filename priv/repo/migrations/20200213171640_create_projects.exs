defmodule Adoptoposs.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :string, default: ""
      add :language, :string, null: false
      add :data, :map, null: false
      add :repo_id, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:projects, [:name])
    create index(:projects, [:language])
    create unique_index(:projects, [:user_id, :repo_id])
  end
end
