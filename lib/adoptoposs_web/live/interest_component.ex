defmodule AdoptopossWeb.InterestComponent do
  use AdoptopossWeb, :live_component

  alias Adoptoposs.{Accounts, Communication, Submissions}
  alias Adoptoposs.Communication.Interest
  alias AdoptopossWeb.Mailer

  @impl true
  def render(assigns) do
    AdoptopossWeb.InterestView.render("actions.html", assigns)
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, to_be_contacted: false)}
  end

  @impl true
  def handle_event("attempt_contact", _, %{assigns: assigns} = socket) do
    interest = %Interest{creator_id: assigns.user_id, project_id: assigns.project_id}
    changeset = Communication.change_interest(interest)
    {:noreply, assign(socket, changeset: changeset, to_be_contacted: true)}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, changeset: nil, to_be_contacted: false)}
  end

  @impl true
  def handle_event("submit", %{"interest" => %{"message" => message}}, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    project = Submissions.get_project!(socket.assigns.project_id)
    attrs = %{creator_id: user.id, project_id: project.id, message: message}

    with :ok <- Bodyguard.permit(Communication, :create_interest, user, project),
         {:ok, interest} <- Communication.create_interest(attrs) do
      send_notification(interest)
      {:noreply, assign(socket, changeset: nil, contacted: true, to_be_contacted: false)}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp send_notification(%Interest{id: id}) do
    interest = Communication.get_interest!(id)

    if interest.project.user.settings.email_when_contacted == "immediately" do
      Mailer.send_interest_received_email(interest)
    end
  end
end
