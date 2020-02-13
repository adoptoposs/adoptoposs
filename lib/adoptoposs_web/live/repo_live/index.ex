defmodule AdoptopossWeb.RepoLive.Index do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.{Endpoint, RepoView}
  alias Adoptoposs.Network
  alias Adoptoposs.Network.Organization

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

  def handle_params(%{"organization_id" => id}, _uri, socket) do
    {:noreply, update_selected(socket, id)}
  end

  defp init_data(socket, token, user) do
    provider = user.provider
    {orga_page_info, organizations} = Network.organizations(token, provider, @orga_limit)

    organization = %Organization{id: user.username, name: user.name, avatar_url: user.avatar_url}
    organizations = [organization | organizations]

    assign(socket, %{
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

    assign(socket, %{
      organization: organization,
      repositories: repositories,
      repo_page_info: repo_page_info
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
