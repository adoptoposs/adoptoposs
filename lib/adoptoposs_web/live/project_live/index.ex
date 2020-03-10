defmodule AdoptopossWeb.ProjectLive.Index do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Submissions, Accounts}
  alias AdoptopossWeb.ProjectView

  def render(assigns) do
    Phoenix.View.render(ProjectView, "index.html", assigns)
  end

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_user(session)
     |> assign_projects(session)
     |> assign(edit_id: nil, remove_id: nil)}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, assign(socket, edit_id: id, remove_id: nil)}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, edit_id: nil)}
  end

  def handle_event("update", %{"id" => id, "message" => description}, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    project = Submissions.get_project!(id)

    with :ok <- Bodyguard.permit(Submissions, :update_project, user, project),
         {:ok, _project} <- Submissions.update_project(project, %{description: description}) do
      projects = Submissions.list_projects(user)
      {:noreply, assign(socket, projects: projects, edit_id: nil)}
    else
      {:error, _} -> {:noreply, socket}
    end
  end

  def handle_event("attempt_remove", %{"id" => id}, socket) do
    {:noreply, assign(socket, remove_id: id, edit_id: nil)}
  end

  def handle_event("cancel_remove", _params, socket) do
    {:noreply, assign(socket, remove_id: nil)}
  end

  def handle_event("remove", %{"id" => id}, socket) do
    user = %Accounts.User{id: socket.assigns.user_id}
    project = Submissions.get_project!(id)

    with :ok <- Bodyguard.permit(Submissions, :delete_project, user, project),
         {:ok, project} <- Submissions.delete_project(project) do
      projects = socket.assigns.projects |> Enum.drop_while(&(&1.id == project.id))
      {:noreply, assign(socket, projects: projects)}
    else
      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp assign_projects(socket, %{"user_id" => user_id}) do
    projects =
      user_id
      |> Accounts.get_user!()
      |> Submissions.list_projects()

    assign(socket, projects: projects)
  end
end
