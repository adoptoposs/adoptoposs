defmodule AdoptopossWeb.Router do
  use AdoptopossWeb, :router
  alias AdoptopossWeb.Plugs

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :browser do
    # Setup HTTP basic auth only if the user & password is set:
    @username Application.get_env(:adoptoposs, :basic_auth)[:username]
    @password Application.get_env(:adoptoposs, :basic_auth)[:password]

    if @username && @password do
      plug BasicAuth, use_config: {:adoptoposs, :basic_auth}
    end

    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, {AdoptopossWeb.LayoutView, "root.html"}
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NavigationHistory.Tracker, excluded_paths: ["/", ~r{/auth/.*}]
    plug Plugs.CurrentUser
    plug Plugs.PutNotificationCount
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

    get "/faq", PageController, :faq
    get "/privacy", PageController, :privacy

    get "/p/:uuid", SharingController, :index
    live "/projects/:uuid", SharingLive

    live "/explore", ExploreLive
  end

  # Routes that require authentication:
  scope "/", AdoptopossWeb do
    pipe_through [:browser, :require_login]

    get "/logout", AuthController, :delete
    get "/settings/repos", RepoController, :index
    live "/settings/repos/:organization_id", RepoLive
    live "/settings/projects", ProjectLive.Index
    live "/projects/:id/messages", ProjectLive.Show
    live "/settings", SettingsLive
    live "/messages/interests", MessagesLive.Interests
    live "/messages/contacted", MessagesLive.Contacted
  end

  scope "/auth", AdoptopossWeb do
    pipe_through :browser
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", AdoptopossWeb do
  #   pipe_through :api
  # end
end
