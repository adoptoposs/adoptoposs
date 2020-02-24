defmodule AdoptopossWeb.ProjectLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.Dashboard
  alias AdoptopossWeb.ProjectView

  def render(assigns) do
    Phoenix.View.render(ProjectView, "index.html", assigns)
  end

  def mount(_params, %{"current_user" => user}, socket) do
    projects = Dashboard.list_projects(user)

    {:ok,
     assign(socket,
       user_id: user.id,
       projects: projects,
       edit_id: nil
     )}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, assign(socket, edit_id: id)}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, edit_id: nil)}
  end

  def handle_event("update", %{"id" => id, "message" => description}, socket) do
    {:ok, project} =
      id
      |> Dashboard.get_project!()
      |> Dashboard.update_project(%{description: description})

    projects = Dashboard.list_projects(project.user)

    {:noreply, assign(socket, projects: projects, edit_id: nil)}
  end

  def handle_event("remove", %{"id" => id}, socket) do
    project = Dashboard.get_project!(id)
    {:ok, project} = Dashboard.delete_project(project)
    projects = socket.assigns.projects |> Enum.drop_while(&(&1.id == project.id))

    {:noreply, assign(socket, projects: projects)}
  end
end
