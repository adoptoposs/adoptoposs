defmodule AdoptopossWeb.RepoLive.Index do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.{Endpoint, RepoView}
  alias Adoptoposs.{Network, Dashboard}
  alias Adoptoposs.Network.Organization
  alias Adoptoposs.Accounts.User

  @orga_limit 10
  @repo_limit 15

  def render(assigns) do
    Phoenix.View.render(RepoView, "index.html", assigns)
  end

  def mount(_params, %{"current_user" => user, "token" => token}, socket) do
    {:ok, init_data(socket, token, user)}
  end

  def handle_event("organization_selected", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, id))}
  end

  def handle_event("attempt_submit", %{"repo-id" => repo_id}, socket) do
    {:noreply, assign(socket, to_be_submitted: repo_id)}
  end

  def handle_event("attempt_edit", %{"repo-id" => repo_id}, socket) do
    project = Dashboard.get_project!(socket.assigns.user_id, repo_id)

    {:noreply,
     assign(socket, to_be_submitted: nil, to_be_edited: repo_id, description: project.description)}
  end

  def handle_event("cancel_submit", _params, socket) do
    {:noreply, assign(socket, to_be_submitted: nil, to_be_edited: nil, description: nil)}
  end

  def handle_event(
        "submit_project",
        %{"repo_id" => repo_id, "description" => description},
        socket
      ) do
    %{repositories: repos, submitted_repos: submitted_repos} = socket.assigns
    repository = repos |> Enum.find(&(&1.id == repo_id))
    attrs = %{user_id: socket.assigns.user_id, description: description}

    case Dashboard.create_project(repository, attrs) do
      {:ok, _project} ->
        {:noreply,
         assign(socket, submitted_repos: [repo_id | submitted_repos], to_be_submitted: nil)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("remove_project", %{"repo-id" => repo_id}, socket) do
    %{submitted_repos: submitted_repos, user_id: user_id} = socket.assigns
    attrs = %{user_id: user_id, repo_id: repo_id}

    case Dashboard.delete_project_by(attrs) do
      {:ok, _project} ->
        submitted_repos = submitted_repos |> Enum.drop_while(&(&1 == repo_id))

        {:noreply,
         assign(socket,
           submitted_repos: submitted_repos,
           to_be_submitted: nil,
           to_be_edited: nil,
           description: nil
         )}

      _ ->
        {:noreply,
         assign(socket,
           to_be_submitted: nil,
           to_be_edited: nil,
           description: nil
         )}
    end
  end

  def handle_event(
        "update_project",
        %{"repo_id" => repo_id, "description" => description},
        socket
      ) do
    %{user_id: user_id} = socket.assigns
    attrs = %{user_id: user_id, repo_id: repo_id, description: description}

    case Dashboard.update_project(attrs) do
      {:ok, _project} ->
        {:noreply, assign(socket, to_be_edited: nil, to_be_submitted: nil, description: nil)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_params(%{"organization_id" => id}, _uri, socket) do
    {:noreply, update_selected(socket, id)}
  end

  defp init_data(socket, token, user) do
    provider = user.provider
    {orga_page_info, organizations} = Network.organizations(token, provider, @orga_limit)

    organization = %Organization{id: user.username, name: user.name, avatar_url: user.avatar_url}
    organizations = [organization | organizations]

    assign(socket, %{
      user_id: user.id,
      token: sign_token(token, provider),
      provider: user.provider,
      username: user.username,
      organizations: organizations,
      orga_page_info: orga_page_info
    })
  end

  defp update_selected(socket, id) do
    {repo_page_info, repositories} = fetch_repo_data(socket, id)
    organization = socket.assigns.organizations |> Enum.find(&(&1.id == id))
    projects = Dashboard.list_projects(%User{id: socket.assigns.user_id})
    submitted_repos = projects |> Enum.map(& &1.repo_id)

    assign(socket, %{
      organization: organization,
      repositories: repositories,
      repo_page_info: repo_page_info,
      submitted_repos: submitted_repos,
      to_be_submitted: nil,
      to_be_edited: nil,
      description: nil
    })
  end

  defp fetch_repo_data(%{assigns: %{username: id}} = socket, id) do
    %{token: token, provider: provider} = socket.assigns
    token = verify_token(token, provider)
    Network.user_repos(token, provider, @repo_limit)
  end

  defp fetch_repo_data(socket, id) do
    %{token: token, provider: provider} = socket.assigns
    token = verify_token(token, provider)
    Network.repos(token, provider, id, @repo_limit)
  end

  defp sign_token(token, salt) do
    Phoenix.Token.sign(Endpoint, salt, token)
  end

  def verify_token(token, salt) do
    {:ok, token} = Phoenix.Token.verify(Endpoint, salt, token, max_age: 86400)
    token
  end
end
