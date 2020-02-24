defmodule Adoptoposs.Repo.Migrations.AddMessageToInterests do
  use Ecto.Migration

  def change do
    alter table(:interests) do
      add :message, :string, default: ""
    end
  end
end
