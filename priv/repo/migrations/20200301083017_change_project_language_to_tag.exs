defmodule Adoptoposs.Repo.Migrations.ChangeProjectLanguageToTag do
  use Ecto.Migration

  import Ecto.Query, only: [from: 2]
  alias Adoptoposs.Repo

  def up do
    alter table(:projects) do
      add :language_id, references(:tags)
    end

    # ensure the new column is added
    flush()

    # copy over tag ids by comparing tag name and language
    from(p in "projects",
      join: t in "tags",
      where: fragment("lower(?) = lower(?)", t.name, p.language),
      update: [set: [language_id: t.id]]
    )
    |> Repo.update_all([])

    alter table(:projects) do
      remove(:language)
    end

    create index(:projects, :language_id)
  end

  def down do
    drop index(:projects, :language_id)

    alter table(:projects) do
      add(:language, :string)
    end

    # ensure the new column is added
    flush()

    # copy over language from the referenced tag
    from(p in "projects",
      join: t in "tags",
      where: p.language_id == t.id,
      update: [set: [language: t.name]]
    )
    |> Repo.update_all([])

    alter table(:projects) do
      remove(:language_id)
    end
  end
end
