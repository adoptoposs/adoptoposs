defmodule AdoptopossWeb.Router do
  use AdoptopossWeb, :router
  use Honeybadger.Plug

  alias AdoptopossWeb.Plugs

  pipeline :browser do
    plug Plugs.BasicAuth
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AdoptopossWeb.LayoutView, :root}
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

    live "/explore", ExploreLive.Index
  end

  # Routes that require authentication:
  scope "/", AdoptopossWeb do
    pipe_through [:browser, :require_login]

    get "/logout", AuthController, :delete
    get "/settings/repos", RepoController, :index
    live "/settings/repos/:organization_id", RepoLive
    live "/settings/projects", ProjectLive
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

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Bamboo.SentEmailViewerPlug
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AdoptopossWeb.Telemetry
    end
  end
end
