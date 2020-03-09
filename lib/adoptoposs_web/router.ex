defmodule AdoptopossWeb.Router do
  use AdoptopossWeb, :router
  alias AdoptopossWeb.Plugs

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :browser do
    # Setup HTTP basic auth only if the user & password is set:
    if System.get_env("BASIC_AUTH_USER") && System.get_env("BASIC_AUTH_PASSWORD") do
      plug BasicAuth, use_config: {:adoptoposs, :basic_auth}
    end

    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_live_layout, {AdoptopossWeb.LayoutView, "app.html"}
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NavigationHistory.Tracker, excluded_paths: ["/", ~r{/auth/.*}]
    plug Plugs.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_login do
    plug Plugs.RequireLogin
  end

  # Routes that are accessible for all users:
  scope "/", AdoptopossWeb do
    pipe_through :browser

    live "/", LandingPageLive
    live "/search", SearchLive
  end

  # Routes that require authentication:
  scope "/", AdoptopossWeb do
    pipe_through [:browser, :require_login]

    get "/settings/repos", RepoController, :index
    live "/settings/repos/:organization_id", RepoLive
    live "/settings/projects", ProjectLive.Index
    live "/projects/:id", ProjectLive.Show
    live "/settings", SettingsLive
  end

  scope "/auth", AdoptopossWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    get "/:provider/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", AdoptopossWeb do
  #   pipe_through :api
  # end
end
