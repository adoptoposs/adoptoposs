defmodule AdoptopossWeb.ProjectLive.Show do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.Dashboard
  alias AdoptopossWeb.ProjectView

  def render(assigns) do
    Phoenix.View.render(ProjectView, "show.html", assigns)
  end

  def mount(%{"id" => id}, %{"current_user" => user}, socket) do
    case Dashboard.get_user_project(user, id) do
      nil ->
        {:ok, push_redirect(socket, to: Routes.live_path(socket, AdoptopossWeb.ProjectLive.Index))}
      project ->
        {:ok, assign(socket, user_id: user.id, project: project)}
    end
  end
end
