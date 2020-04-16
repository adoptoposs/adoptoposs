# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :adoptoposs, Adoptoposs.Repo,
  ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

live_view_signing_salt =
  System.get_env("LIVE_VIEW_SIGNING_SALT") ||
    raise """
    environment variable LIVE_VIEW_SIGNING_SALT is missing.
    You can generate one by calling: mix phx.gen.secret 32
    """

config :adoptoposs, AdoptopossWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base,
  live_view: [signing_salt: live_view_signing_salt]

github_client_id =
  System.get_env("GITHUB_CLIENT_ID") ||
    raise """
    environment variable GITHUB_CLIENT_ID is missing.
    See https://github.com/settings/apps
    """

github_client_secret =
  System.get_env("GITHUB_CLIENT_SECRET") ||
    raise """
    environment variable GITHUB_CLIENT_SECRET is missing.
    See https://github.com/settings/apps
    """

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: github_client_id,
  client_secret: github_client_secret

# Basic Auth
config :adoptoposs, :basic_auth,
  realm: "Only Team members",
  username: System.get_env("BASIC_AUTH_USER"),
  password: System.get_env("BASIC_AUTH_PASSWORD")

# Mailing
email_api_key =
  System.get_env("MAILGUN_API_KEY") ||
    System.get_env("EMAIL_API_KEY") ||
    raise """
    environment variable MAILGUN_API_KEY and EMAIL_API_KEY is missing.
    Please set one of them.
    See your MailGun Account.
    """

email_domain = System.get_env("MAILGUN_DOMAIN") || System.get_env("EMAIL_DOMAIN")
email_base_uri = System.get_env("MAILGUN_BASE_URI") || System.get_env("EMAIL_BASE_URI")

config :adoptoposs, AdoptopossWeb.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: email_api_key,
  domain: email_domain,
  base_uri: email_base_uri,
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ]

# Performance monitoring
config :new_relic_agent,
  app_name: System.get_env("NEW_RELIC_APP_NAME") || "Adoptoposs",
  license_key: System.get_env("NEW_RELIC_LICENSE_KEY")

config :adoptoposs, AdoptopossWeb.Endpoint, instrumenters: [NewRelic.Phoenix.Instrumenter]

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :adoptoposs, AdoptopossWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
