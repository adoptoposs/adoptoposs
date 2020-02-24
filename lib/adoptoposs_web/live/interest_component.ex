defmodule AdoptopossWeb.InterestComponent do
  use AdoptopossWeb, :live_component

  alias Adoptoposs.{Accounts, Communication}

  def render(assigns) do
    AdoptopossWeb.InterestView.render("actions.html", assigns)
  end

  def mount(socket) do
    {:ok, assign(socket, to_be_contacted: false)}
  end

  def handle_event("attempt_contact", _, socket) do
    {:noreply, assign(socket, to_be_contacted: true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, to_be_contacted: false)}
  end

  def handle_event("submit", %{"message" => message}, %{assigns: assigns} = socket) do
    user = Accounts.get_user!(assigns.user_id)
    attrs = %{creator_id: user.id, project_id: assigns.project_id, message: message}
    {:ok, _} = Communication.create_interest(attrs)

    {:noreply, assign(socket, contacted: true, to_be_contacted: false)}
  end
end
