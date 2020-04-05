defmodule Adoptoposs.Repo.Migrations.AddUuidToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :uuid, :binary_id, default: fragment("gen_random_uuid()")
    end

    create unique_index(:projects, :uuid)
  end
end
