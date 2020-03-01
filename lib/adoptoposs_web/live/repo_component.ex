defmodule AdoptopossWeb.RepoComponent do
  use AdoptopossWeb, :live_component

  alias Adoptoposs.{Dashboard, Tags}

  def render(assigns) do
    AdoptopossWeb.RepoView.render("repo.html", assigns)
  end

  def handle_event("attempt_submit", _, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, to_be_submitted: assigns.repo.id)}
  end

  def handle_event("cancel_submit", _, socket) do
    {:noreply, assign(socket, to_be_submitted: nil)}
  end

  def handle_event("submit_project", %{"message" => description}, socket) do
    %{repo: repository, user_id: user_id} = socket.assigns
    tag = Tags.get_tag_by_name!(repository.language.name)
    attrs = %{user_id: user_id, language_id: tag.id, description: description}

    case Dashboard.create_project(repository, attrs) do
      {:ok, _project} ->
        {:noreply, assign(socket, submitted: true, to_be_submitted: nil)}

      _ ->
        {:noreply, socket}
    end
  end
end
