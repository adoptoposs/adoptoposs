defmodule AdoptopossWeb.ProjectController do
  use AdoptopossWeb, :controller

  alias Adoptoposs.Network
  alias Adoptoposs.Network.Organization
  alias Adoptoposs.Accounts.User

  @orga_limit 10
  @repo_limit 15
  @start_cursor ""

  def index(conn, _params) do
    token = get_session(conn, :token)
    user = get_session(conn, :current_user)
    provider = user.provider

    {orga_page_info, organizations} = Network.organizations(token, provider, @orga_limit)
    organization = %Organization{id: user.username, name: user.name, avatar_url: user.avatar_url}

    {repo_page_info, repositories} =
      if organization.id == user.username do
        Network.user_repos(token, provider, @repo_limit)
      else
        Network.repos(token, provider, organization.id, @repo_limit)
      end

    render(conn, "index.html",
      organizations: [organization | organizations],
      organization: organization,
      orga_page_info: orga_page_info,
      repositories: repositories,
      repo_page_info: repo_page_info
    )
  end
end
