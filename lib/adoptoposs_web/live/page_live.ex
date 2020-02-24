defmodule AdoptopossWeb.PageLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Dashboard, Accounts}
  alias AdoptopossWeb.PageView

  def render(assigns) do
    Phoenix.View.render(PageView, "index.html", assigns)
  end

  def mount(_params, session, socket) do
    projects = Dashboard.list_projects(limit: 6)

    {:ok,
    socket
    |> assign_user(session)
    |> assign(projects: projects)}
  end

  defp assign_user(socket, %{"current_user" => user}) do
    assign(socket, user_id: user.id)
  end

  defp assign_user(socket, session) do
    assign(socket, user_id: nil)
  end
end
