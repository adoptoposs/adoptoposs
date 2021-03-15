defmodule AdoptopossWeb.MessagesLive.Contacted do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.MessagesView
  alias Adoptoposs.Accounts

  @impl true
  def render(assigns) do
    Phoenix.View.render(MessagesView, "contacted.html", assigns)
  end

  @impl true
  def mount_logged_in(_params, %{"user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id, preload: [tag_subscriptions: [:tag]])
    {:ok, socket |> assign_interests(user)}
  end

  defp assign_interests(socket, user) do
    assign(socket, interests: Communication.list_user_interests(user))
  end
end
