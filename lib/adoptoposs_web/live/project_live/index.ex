defmodule AdoptopossWeb.ProjectLive.Index do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Dashboard, Accounts}
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
       edit_id: nil,
       remove_id: nil
     )}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, assign(socket, edit_id: id, remove_id: nil)}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, edit_id: nil)}
  end

  def handle_event("update", %{"id" => id, "message" => description}, socket) do
    user = %Accounts.User{id: socket.assigns.user_id}

    {:ok, project} =
      user
      |> Dashboard.get_user_project(id)
      |> Dashboard.update_project(%{description: description})

    projects = Dashboard.list_projects(project.user)

    {:noreply, assign(socket, projects: projects, edit_id: nil)}
  end

  def handle_event("attempt_remove", %{"id" => id}, socket) do
    {:noreply, assign(socket, remove_id: id, edit_id: nil)}
  end

  def handle_event("cancel_remove", _params, socket) do
    {:noreply, assign(socket, remove_id: nil)}
  end

  def handle_event("remove", %{"id" => id}, socket) do
    user = %Accounts.User{id: socket.assigns.user_id}
    project = Dashboard.get_user_project(user, id)
    {:ok, project} = Dashboard.delete_project(project)
    projects = socket.assigns.projects |> Enum.drop_while(&(&1.id == project.id))

    {:noreply, assign(socket, projects: projects)}
  end
end
