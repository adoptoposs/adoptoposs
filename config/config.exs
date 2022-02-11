# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

if Mix.env() == :dev do
  config :mix_test_watch,
    clear: true
end

config :adoptoposs,
  ecto_repos: [Adoptoposs.Repo]

# Configures the endpoint
config :adoptoposs, AdoptopossWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2huvB6wFDsQJGkJYw5712sNJJeFD+itR0VApi8VLNNSFQZG79+Bv6FI6cPpbaCm/",
  render_errors: [
    view: AdoptopossWeb.ErrorView,
    accepts: ~w(html json),
    layout: {AdoptopossWeb.LayoutView, "error.html"}
  ],
  pubsub_server: Adoptoposs.PubSub,
  live_view: [signing_salt: "r3nJpTPt6vBQikTcL+RKVfzNTFcxrm99"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Authentication
github_api_scopes = Enum.join(~w(read:user user:email read:org), ",")

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: github_api_scopes]}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
