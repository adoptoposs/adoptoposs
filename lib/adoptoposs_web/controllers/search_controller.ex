defmodule AdoptopossWeb.SearchController do
  use AdoptopossWeb, :controller

  alias Adoptoposs.Accounts.User
  alias Adoptoposs.{Network, Projects}

  @default_limit 15
  @default_type "maintainer"

  def index(conn, %{"q" => query, "limit" => limit, "type" => type}) do
    %User{provider: provider} = get_session(conn, :current_user)

    results =
      conn
      |> get_session(:token)
      |> Network.search_repos(provider, query, limit)
      |> Projects.filter(type)

    render(conn, "index.html", results: results, query: query)
  end

  def index(conn, %{"q" => _query, "type" => _type} = params) do
    index(conn, Map.put(params, "limit", @default_limit))
  end

  def index(conn, %{"q" => _query} = params) do
    params =
      params
      |> Map.put("limit", @default_limit)
      |> Map.put("type", @default_type)

    index(conn, params)
  end

  def index(conn, _params) do
    render(conn, "index.html", results: [], query: "")
  end
end
