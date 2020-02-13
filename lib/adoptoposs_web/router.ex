defmodule AdoptopossWeb.Router do
  use AdoptopossWeb, :router
  alias AdoptopossWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plugs.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Routes that are accessible for all users:
  scope "/", AdoptopossWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Routes that require authentication:
  scope "/", AdoptopossWeb do
    pipe_through [:browser, Plugs.RequireLogin]

    get "/repos", RepoController, :index
    live "/repos/:organization_id", RepoLive.Index
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
