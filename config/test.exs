import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :adoptoposs, Adoptoposs.Repo,
  username: "postgres",
  password: "postgres",
  database: "adoptoposs_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "db",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :adoptoposs, AdoptopossWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KDGVtUF6ww0E+2IAOZ/Vcr7iQuELHJ/xGduy7PsBDqA8eHyqKDPayOaORfWOCUYf",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# External APIs
config :adoptoposs, :github_api, Adoptoposs.Network.Api.GithubInMemory

# Mailing
config :adoptoposs, AdoptopossWeb.Mailer, adapter: Bamboo.TestAdapter
config :bamboo, :refute_timeout, 10

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Error Monitoring
config :honeybadger, environment_name: :test
