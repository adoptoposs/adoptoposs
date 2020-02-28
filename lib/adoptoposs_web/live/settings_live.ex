defmodule AdoptopossWeb.SettingsLive do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.SettingsView

  def render(assigns) do
    Phoenix.View.render(SettingsView, "index.html", assigns)
  end

  def mount(_params, %{"current_user" => user} = session, socket) do
    {:ok, assign(socket, current_user: user)}
  end
end
