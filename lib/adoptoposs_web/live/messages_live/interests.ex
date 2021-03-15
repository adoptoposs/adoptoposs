defmodule AdoptopossWeb.MessagesLive.Interests do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.MessagesView

  @impl true
  def render(assigns) do
    Phoenix.View.render(MessagesView, "interests.html", assigns)
  end

  @impl true
  def mount_logged_in(_params, %{"user_id" => user_id}, socket) do
    {:ok, socket |> assign_interests(user_id)}
  end

  defp assign_interests(socket, user_id) do
    assign(socket, interests: Communication.list_user_project_interests(user_id))
  end
end
