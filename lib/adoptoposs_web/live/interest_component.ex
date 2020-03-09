defmodule AdoptopossWeb.InterestComponent do
  use AdoptopossWeb, :live_component

  alias Adoptoposs.{Accounts, Communication, Dashboard}
  alias Adoptoposs.Communication.Interest
  alias AdoptopossWeb.Mailer

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
    project = Dashboard.get_project!(assigns.project_id)
    attrs = %{creator_id: user.id, project_id: project.id, message: message}

    with :ok <- Bodyguard.permit(Communication, :create_interest, user, project),
         {:ok, interest} <- Communication.create_interest(attrs) do
      send_notification(interest)
      {:noreply, assign(socket, contacted: true, to_be_contacted: false)}
    else
      {:error, _} -> {:noreply, socket}
    end
  end

  defp send_notification(%Interest{id: id}) do
    interest = Communication.get_interest!(id)

    if interest.project.user.settings.email_when_contacted == "immediately" do
      Mailer.send_interest_received_email(interest)
    end
  end
end
