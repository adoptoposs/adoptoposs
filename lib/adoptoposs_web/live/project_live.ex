defmodule AdoptopossWeb.ProjectLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Submissions, Accounts}
  alias AdoptopossWeb.ProjectView

  @impl true
  def render(assigns) do
    Phoenix.View.render(ProjectView, "index.html", assigns)
  end

  @impl true
  def mount_logged_in(_params, session, socket) do
    {:ok,
     socket
     |> assign_user(session)
     |> assign_projects(session)
     |> assign(changeset: nil, edit_id: nil, remove_id: nil)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    project = Submissions.get_project!(id)
    changeset = Submissions.change_project(project)

    {:noreply,
     assign(socket,
       changeset: changeset,
       edit_id: project.id,
       remove_id: nil
     )}
  end

  @impl true
  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, changeset: nil, edit_id: nil)}
  end

  @impl true
  def handle_event("update", %{"project" => %{"description" => description}}, socket) do
    update_project(socket.assigns.edit_id, socket, fn project ->
      Submissions.update_project(project, %{description: description})
    end)
  end

  @impl true
  def handle_event("publish", %{"id" => id}, socket) do
    update_project(id, socket, fn project ->
      Submissions.update_project_status(project, :published)
    end)
  end

  @impl true
  def handle_event("unpublish", %{"id" => id}, socket) do
    update_project(id, socket, fn project ->
      Submissions.update_project_status(project, :draft)
    end)
  end

  @impl true
  def handle_event("attempt_remove", %{"id" => id}, socket) do
    {:noreply, assign(socket, remove_id: id, edit_id: nil)}
  end

  @impl true
  def handle_event("cancel_remove", _params, socket) do
    {:noreply, assign(socket, remove_id: nil)}
  end

  @impl true
  def handle_event("remove", %{"id" => id}, socket) do
    user = %Accounts.User{id: socket.assigns.user_id}
    project = Submissions.get_project!(id)

    with :ok <- Bodyguard.permit(Submissions, :delete_project, user, project),
         {:ok, _project} <- Submissions.delete_project(project) do
      projects = Submissions.list_projects(user)
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

  defp update_project(project_id, socket, callback) do
    user = Accounts.get_user!(socket.assigns.user_id)
    project = Submissions.get_project!(project_id)

    with :ok <- Bodyguard.permit(Submissions, :update_project, user, project),
         {:ok, _project} <- callback.(project) do
      projects = Submissions.list_projects(user)
      {:noreply, assign(socket, projects: projects, edit_id: nil)}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
