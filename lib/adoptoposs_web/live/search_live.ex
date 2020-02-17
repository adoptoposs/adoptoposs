defmodule AdoptopossWeb.SearchLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.Search
  alias AdoptopossWeb.SearchView

  @default_limit 12

  def render(assigns) do
    Phoenix.View.render(SearchView, "index.html", assigns)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: nil, offset: 0, projects: nil, loading: false)}
  end

  def handle_event("search", %{"q" => query} = params, socket) do
    query = String.trim(query)

    if query == "" do
      {:noreply, socket}
    else
      send(self(), {:search, params})
      {:noreply, assign(socket, loading: true, query: query)}
    end
  end

  def handle_info({:search, params}, socket) do
    search(socket, params)
  end

  def search(socket, %{"q" => query} = params) do
    offset = params["offset"] || 0
    limit = params["limit"] || @default_limit

    projects = Search.find_projects(query, offset: offset, limit: limit)

    {:noreply,
     assign(socket,
       query: query,
       offset: offset,
       limit: limit,
       projects: projects,
       loading: false
     )}
  end
end
