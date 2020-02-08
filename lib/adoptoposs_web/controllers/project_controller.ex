defmodule AdoptopossWeb.ProjectController do
  use AdoptopossWeb, :controller

  alias Adoptoposs.Network
  alias Adoptoposs.Accounts.User

  @orga_limit 10
  @repo_limit 15
  @start_cursor ""

  def index(conn, _params) do
    token = get_session(conn, :token)
    provider = get_provider(conn)

    {orga_page_info, [organization | _] = organizations} =
      Network.organizations(token, provider, @orga_limit)

    {repo_page_info, repositories} = Network.repos(token, provider, organization.id, @repo_limit)

    render(conn, "index.html",
      organizations: organizations,
      organization: organization,
      orga_page_info: orga_page_info,
      repositories: repositories,
      repo_page_info: repo_page_info
    )
  end

  defp get_provider(conn) do
    %User{provider: provider} = get_session(conn, :current_user)
    provider
  end
end
