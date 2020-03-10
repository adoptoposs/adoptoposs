defmodule AdoptopossWeb.ProjectLive.Show do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Accounts, Dashboard}
  alias AdoptopossWeb.{ProjectView, ProjectLive}

  def render(assigns) do
    Phoenix.View.render(ProjectView, "show.html", assigns)
  end

  def mount(%{"id" => id}, %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    project = Dashboard.get_project!(id, preload: [interests: [:creator, project: [:user]]])

    with :ok <- Bodyguard.permit(Dashboard, :show_project, user, project) do
      {:ok, assign(socket, user_id: user_id, project: project)}
    else
      {:error, _} ->
        {:ok, push_redirect(socket, to: Routes.live_path(socket, ProjectLive.Index))}
    end
  end
end
