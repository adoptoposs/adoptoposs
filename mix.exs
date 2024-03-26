defmodule Adoptoposs.MixProject do
  use Mix.Project

  def project do
    [
      app: :adoptoposs,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Adoptoposs.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.1"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 0.18.18"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      # ---------------------------
      # additional packages:
      # ---------------------------
      {:ueberauth, "~> 0.10.7"},
      {:ueberauth_github, "~> 0.8"},
      {:bodyguard, "~> 2.4"},
      {:httpoison, "~> 2.0"},
      {:timex, "~> 3.7"},
      {:earmark, "~> 1.4"},
      {:yaml_elixir, "~> 2.6"},
      {:bamboo, "~> 2.2"},
      {:bamboo_phoenix, "~> 1.0"},
      {:mjml, "~> 3.0"},
      {:navigation_history, "~> 0.4"},
      {:quantum, "~> 3.5.0"},
      {:honeybadger, "~> 0.19"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:ex_machina, "~> 2.7", only: [:dev, :test]},
      {:hammox, "~> 0.7.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "fetch.languages": ["run priv/repo/fetch_languages.exs"],
      "update.github_repos": ["run priv/repo/update_repo_data.exs --provider github"],
      setup: ["deps.get", "ecto.setup", "cmd --cd assets yarn install"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "fetch.languages", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["cmd --cd assets node build.js --deploy", "phx.digest"]
    ]
  end
end
