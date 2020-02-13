defmodule AdoptopossWeb.RepoLive.Index do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.{Endpoint, RepoView}
  alias Adoptoposs.Network
  alias Adoptoposs.Network.Organization
  alias Adoptoposs.Accounts.User

  @orga_limit 10
  @repo_limit 15
  @start_cursor ""

  def render(assigns) do
    Phoenix.View.render(RepoView, "index.html", assigns)
  end

  def mount(%{"organization_id" => id}, session, socket) do
    %{"current_user" => %User{provider: provider} = user, "token" => token} = session
    data = init_data(token, user, id)

    session_data = %{
      token: sign_token(token, provider),
      provider: user.provider,
      username: user.username
    }

    {:ok, assign(socket, Map.merge(data, session_data))}
  end

  def handle_event("organization_selected", %{"id" => id}, socket) do
    {:noreply, live_redirect(socket, to: Routes.live_path(socket, __MODULE__, id))}
  end

  def handle_params(%{"organization_id" => id}, _uri, socket) do
    data = update_selected(socket, id)
    {:noreply, assign(socket, data)}
  end

  defp init_data(token, %User{username: id} = user, id) do
    provider = user.provider
    {orga_page_info, organizations} = Network.organizations(token, provider, @orga_limit)
    {repo_page_info, repositories} = Network.user_repos(token, provider, @repo_limit)
    organization = %Organization{id: user.username, name: user.name, avatar_url: user.avatar_url}

    %{
      organizations: [organization | organizations],
      organization: organization,
      orga_page_info: orga_page_info,
      repositories: repositories,
      repo_page_info: repo_page_info
    }
  end

  defp init_data(token, user, organization_id) do
    provider = user.provider
    {orga_page_info, organizations} = Network.organizations(token, provider, @orga_limit)
    {repo_page_info, repositories} = Network.repos(token, provider, organization_id, @repo_limit)

    organization = %Organization{id: user.username, name: user.name, avatar_url: user.avatar_url}
    organizations = [organization | organizations]
    organization = organizations |> Enum.find(&(&1.id == organization_id))

    %{
      organizations: organizations,
      organization: organization,
      orga_page_info: orga_page_info,
      repositories: repositories,
      repo_page_info: repo_page_info
    }
  end

  defp update_selected(%{assigns: %{username: id}} = socket, id) do
    %{token: token, provider: provider, organizations: organizations} = socket.assigns
    token = verify_token(token, provider)
    {repo_page_info, repositories} = Network.user_repos(token, provider, @repo_limit)
    [organization | _] = organizations

    %{
      organization: organization,
      repositories: repositories,
      repo_page_info: repo_page_info
    }
  end

  defp update_selected(socket, id) do
    %{token: token, provider: provider, organizations: organizations} = socket.assigns
    token = verify_token(token, provider)
    {repo_page_info, repositories} = Network.repos(token, provider, id, @repo_limit)
    organization = organizations |> Enum.find(&(&1.id == id))

    %{
      organization: organization,
      repositories: repositories,
      repo_page_info: repo_page_info
    }
  end

  defp sign_token(token, salt) do
    Phoenix.Token.sign(Endpoint, salt, token)
  end

  def verify_token(token, salt) do
    {:ok, token} = Phoenix.Token.verify(Endpoint, salt, token, max_age: 86400)
    token
  end
end
