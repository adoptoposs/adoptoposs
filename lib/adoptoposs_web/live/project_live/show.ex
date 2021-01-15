defmodule AdoptopossWeb.ProjectLive.Show do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Accounts, Submissions}
  alias AdoptopossWeb.{ProjectView, ProjectLive}

  @impl true
  def render(assigns) do
    Phoenix.View.render(ProjectView, "show.html", assigns)
  end

  @impl true
  def mount_logged_in(%{"id" => id}, %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    project = Submissions.get_user_project(user, id)

    with :ok <- Bodyguard.permit(Submissions, :show_project, user, project) do
      {:ok, assign(socket, user_id: user_id, project: project)}
    else
      {:error, _} ->
        {:ok, push_redirect(socket, to: Routes.live_path(socket, ProjectLive.Index))}
    end
  end
end
