defmodule Adoptoposs.Repo.Migrations.CreateTagSubscriptions do
  use Ecto.Migration

  def change do
    create table(:tag_subscriptions) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)

      timestamps()
    end

    create index(:tag_subscriptions, [:user_id])
    create index(:tag_subscriptions, [:tag_id])
    create unique_index(:tag_subscriptions, [:user_id, :tag_id])
  end
end
