defmodule Adoptoposs.Release do
  @app :adoptoposs

  require Logger

  alias Adoptoposs.Tags
  alias Adoptoposs.Tags.Tag

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(
          repo,
          &Ecto.Migrator.run(&1, :up, all: true)
        )
    end
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(
        repo,
        &Ecto.Migrator.run(&1, :down, to: version)
      )
  end

  def fetch_languages do
    try do
      Logger.info("fetching programming languages…")

      "https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml"
      |> Tags.Loader.fetch_languages()
      |> List.insert_at(0, Tag.Utility.unknown())
      |> Enum.map(&Map.from_struct/1)
      |> Tags.upsert_tags()

      Logger.info("done")
    rescue
      error in [HTTPoison.Error, File.Error] ->
        Logger.error(error)
        Logger.error("Fetching languages failed. Please run `mix fetch.languages` manually.")
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
