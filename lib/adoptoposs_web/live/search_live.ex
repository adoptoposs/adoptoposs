defmodule AdoptopossWeb.SearchLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.Search
  alias AdoptopossWeb.SearchView

  @per_page 12

  def render(assigns) do
    Phoenix.View.render(SearchView, "index.html", assigns)
  end

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_user(session)
     |> assign(query: nil, page: 1)
     |> update_with_append(), temporary_assigns: [projects: []]}
  end

  def handle_params(params, _uri, %{assigns: assigns} = socket) do
    query = String.trim(params["q"] || "")

    if query == "" || query == assigns.query do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> assign(page: 1)
       |> update_with_replace()
       |> search(query)}
    end
  end

  def handle_event("search", %{"q" => query}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, AdoptopossWeb.SearchLive, q: query))}
  end

  def handle_event("load_more", _, %{assigns: assigns} = socket) do
    {:noreply,
     socket
     |> assign(page: assigns.page + 1)
     |> update_with_append()
     |> search(assigns.query)}
  end

  defp search(socket, query) do
    offset = (socket.assigns.page - 1) * @per_page
    projects = Search.find_projects(query, offset: offset, limit: @per_page)

    assign(socket, query: query, projects: projects)
  end

  defp assign_user(socket, %{"current_user" => user}) do
    assign(socket, user_id: user.id)
  end

  defp assign_user(socket, _) do
    assign(socket, user_id: nil)
  end

  defp update_with_append(socket) do
    assign(socket, update: "append")
  end

  defp update_with_replace(socket) do
    assign(socket, update: "replace")
  end
end
