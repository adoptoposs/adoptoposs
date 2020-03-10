defmodule AdoptopossWeb.RepoLive do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.{Endpoint, RepoView}
  alias Adoptoposs.{Accounts, Network, Submissions}
  alias Adoptoposs.Network.Organization

  @orga_limit 25
  @repo_limit 10

  def render(assigns) do
    Phoenix.View.render(RepoView, "index.html", assigns)
  end

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(page: 1)
     |> assign_user(session)
     |> update_with_append()
     |> init_data(session), temporary_assigns: [repositories: []]}
  end

  def handle_event("organization_selected", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, id))}
  end

  def handle_event("load_more", _, %{assigns: assigns} = socket) do
    %{has_next_page: has_next_page, end_cursor: after_cursor} = assigns.repo_page_info

    if has_next_page do
      {:noreply,
       socket
       |> update_with_append()
       |> assign(page: assigns.page + 1)
       |> load_repos(assigns.organization.id, after_cursor)}
    else
      {:noreply, socket}
    end
  end

  def handle_params(%{"organization_id" => id}, _uri, socket) do
    {:noreply, update_selected(socket, id)}
  end

  defp init_data(socket, %{"user_id" => user_id, "token" => token}) do
    user = Accounts.get_user!(user_id)
    provider = user.provider
    {orga_page_info, organizations} = Network.organizations(token, provider, @orga_limit)

    organization = %Organization{id: user.username, name: user.name, avatar_url: user.avatar_url}
    organizations = [organization | organizations]

    projects = Submissions.list_projects(user)

    assign(socket, %{
      token: sign_token(token, provider),
      provider: user.provider,
      username: user.username,
      projects: projects,
      organizations: organizations,
      orga_page_info: orga_page_info
    })
  end

  defp update_selected(socket, organization_id) do
    organization = socket.assigns.organizations |> Enum.find(&(&1.id == organization_id))
    projects = Submissions.list_projects(%Accounts.User{id: socket.assigns.user_id})
    submitted_repos = projects |> Enum.map(& &1.repo_id)

    socket
    |> update_with_replace()
    |> load_repos(organization_id)
    |> assign(%{
      organization: organization,
      submitted_repos: submitted_repos,
      to_be_submitted: nil
    })
  end

  defp load_repos(socket, organisation_id, after_cursor \\ "")

  defp load_repos(%{assigns: %{username: id}} = socket, id, after_cursor) do
    %{token: token, provider: provider} = socket.assigns
    token = verify_token(token, provider)
    {page_info, repos} = Network.user_repos(token, provider, @repo_limit, after_cursor)

    assign(socket,
      repositories: repos,
      repo_page_info: page_info
    )
  end

  defp load_repos(socket, organisation_id, after_cursor) do
    %{token: token, provider: provider} = socket.assigns
    token = verify_token(token, provider)

    {page_info, repos} =
      Network.repos(token, provider, organisation_id, @repo_limit, after_cursor)

    assign(socket,
      repositories: repos,
      repo_page_info: page_info
    )
  end

  defp sign_token(token, salt) do
    Phoenix.Token.sign(Endpoint, salt, token)
  end

  def verify_token(token, salt) do
    {:ok, token} = Phoenix.Token.verify(Endpoint, salt, token, max_age: 86400)
    token
  end
end
