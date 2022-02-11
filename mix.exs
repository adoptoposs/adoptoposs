defmodule Adoptoposs.MixProject do
  use Mix.Project

  def project do
    [
      app: :adoptoposs,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
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
      {:phoenix, "~> 1.5.8"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.2"},
      {:ecto_sql, "~> 3.5"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_view, "~> 0.15.4"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.4"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_github, "~> 0.8"},
      {:bodyguard, "~> 2.4"},
      {:httpoison, "~> 1.8"},
      {:timex, "~> 3.7"},
      {:earmark, "~> 1.4"},
      {:basic_auth, "~> 2.2.5"},
      {:yaml_elixir, "~> 2.6"},
      {:bamboo, "~> 1.7"},
      {:mjml, "~> 1.1.2"},
      {:navigation_history, "~> 0.4"},
      {:quantum, "~> 3.0"},
      {:new_relic_agent, "~> 1.0"},
      {:ecto_enum, "~> 1.4"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:ex_machina, "~> 2.7", only: [:dev, :test]},
      {:floki, ">= 0.0.0", only: :test},
      {:hammox, "~> 0.5.0", only: :test}
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
      "ecto.setup": ["ecto.create", "ecto.migrate", "fetch.languages", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
