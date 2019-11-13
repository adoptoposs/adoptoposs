defmodule AdoptopossWeb.SearchController do
  use AdoptopossWeb, :controller

  alias Adoptoposs.Accounts.User
  alias Adoptoposs.Network

  @default_limit 15

  def index(conn, %{"q" => query, "limit" => limit}) do
    %User{provider: provider} = get_session(conn, :current_user)

    results =
      conn
      |> get_session(:token)
      |> Network.search_repos(provider, query, limit)

    render(conn, "index.html", results: results, query: query)
  end

  def index(conn, %{"q" => _query} = params) do
    index(conn, Map.put(params, "limit", @default_limit))
  end

  def index(conn, _params) do
    render(conn, "index.html", results: [], query: "")
  end
end
