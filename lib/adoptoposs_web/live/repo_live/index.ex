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

  def handle_event("cancel_submit", _params, socket) do
    {:noreply, assign(socket, to_be_submitted: nil)}
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

  def handle_params(%{"organization_id" => id}, _uri, socket) do
    {:noreply, update_selected(socket, id)}
  end

  defp init_data(socket, token, user) do
    provider = user.provider
    {orga_page_info, organizations} = Network.organizations(token, provider, @orga_limit)

    organization = %Organization{id: user.username, name: user.name, avatar_url: user.avatar_url}
    organizations = [organization | organizations]

    projects = Dashboard.list_projects(user)

    assign(socket, %{
      user_id: user.id,
      token: sign_token(token, provider),
      provider: user.provider,
      username: user.username,
      projects: projects,
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
      to_be_submitted: nil
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
