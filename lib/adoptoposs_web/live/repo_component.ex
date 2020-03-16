defmodule AdoptopossWeb.RepoComponent do
  use AdoptopossWeb, :live_component

  alias Adoptoposs.{Submissions, Tags}
  alias Adoptoposs.Submissions.Project

  def render(assigns) do
    AdoptopossWeb.RepoView.render("repo.html", assigns)
  end

  def handle_event("attempt_submit", _, %{assigns: assigns} = socket) do
    changeset = Submissions.change_project(%Project{})
    {:noreply, assign(socket, to_be_submitted: assigns.repo.id, changeset: changeset)}
  end

  def handle_event("cancel_submit", _, socket) do
    {:noreply, assign(socket, to_be_submitted: nil)}
  end

  def handle_event("submit_project", %{"project" => %{"description" => description}}, socket) do
    %{repo: repository, user_id: user_id} = socket.assigns
    tag = Tags.get_tag_by_name!(repository.language.name)
    attrs = %{user_id: user_id, language_id: tag.id, description: description}

    case Submissions.create_project(repository, attrs) do
      {:ok, _project} ->
        {:noreply, assign(socket, submitted: true, to_be_submitted: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
