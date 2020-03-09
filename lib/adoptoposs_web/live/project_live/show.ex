defmodule AdoptopossWeb.ProjectLive.Show do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Accounts, Dashboard}
  alias AdoptopossWeb.ProjectView

  def render(assigns) do
    Phoenix.View.render(ProjectView, "show.html", assigns)
  end

  def mount(%{"id" => id}, %{"user_id" => user_id}, socket) do
    project =
      user_id
      |> Accounts.get_user!()
      |> Dashboard.get_user_project(id)

    case project do
      nil ->
        {:ok,
         push_redirect(socket, to: Routes.live_path(socket, AdoptopossWeb.ProjectLive.Index))}

      project ->
        {:ok, assign(socket, user_id: user_id, project: project)}
    end
  end
end
