import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# Start the phoenix server if environment is set and running in a release
if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  config :adoptoposs, Adoptoposs.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :adoptoposs, Adoptoposs.Repo,
    ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "adoptoposs.org"
  port = String.to_integer(System.get_env("PORT") || "4000")

  live_view_signing_salt =
    System.get_env("LIVE_VIEW_SIGNING_SALT") ||
      raise """
      environment variable LIVE_VIEW_SIGNING_SALT is missing.
      You can generate one by calling: mix phx.gen.secret 32
      """

  config :adoptoposs, Adoptoposs.Endpoint,
    url: [host: host, port: 443],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
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

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :adoptoposs, Adoptoposs.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end