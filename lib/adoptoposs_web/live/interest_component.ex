defmodule AdoptopossWeb.InterestComponent do
  use AdoptopossWeb, :live_component

  alias Adoptoposs.{Accounts, Communication}

  def render(assigns) do
    AdoptopossWeb.InterestView.render("actions.html", assigns)
  end

  def handle_event("show_interest", _, %{assigns: assigns} = socket) do
    user = Accounts.get_user!(assigns.user_id)
    attrs = %{creator_id: user.id, project_id: assigns.project_id}
    {:ok, interest} = Communication.create_interest(attrs)

    {:noreply, assign(socket, shown: true)}
  end
end
