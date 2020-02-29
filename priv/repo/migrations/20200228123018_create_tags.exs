defmodule Adoptoposs.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :type, :string
      add :color, :string

      timestamps()
    end

    create index(:tags, :name)
    create index(:tags, :type)
  end
end
