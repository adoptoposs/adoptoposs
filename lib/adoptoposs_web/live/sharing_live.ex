defmodule AdoptopossWeb.SharingLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.Submissions
  alias AdoptopossWeb.SharingView

  def render(assigns) do
    Phoenix.View.render(SharingView, "project.html", assigns)
  end

  def mount(%{"uuid" => uuid}, session, socket) do
    {:ok,
     socket
     |> assign_user(session)
     |> assign_project(uuid)}
  end

  defp assign_project(socket, uuid) do
    options = [preload: [:user, :language, interests: [:creator]]]
    project = Submissions.get_project_by_uuid(uuid, options)
    assign(socket, project: project)
  end
end
