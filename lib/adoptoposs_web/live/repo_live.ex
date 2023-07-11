defmodule AdoptopossWeb.RepoLive do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.{Endpoint, RepoView}
  alias Adoptoposs.{Accounts, Network, Submissions}
  alias Adoptoposs.Network.Organization

  @orga_limit 25
  @repo_limit 10

  @impl true
  def render(assigns) do
    Phoenix.View.render(RepoView, "index.html", assigns)
  end

  @impl true
  def mount_logged_in(_params, %{"user_id" => user_id} = session, socket) do
    user = Accounts.get_user!(user_id)

    {:ok,
     socket
     |> assign_user(session)
     |> assign_token(session, user.provider)
     |> put_assigns(session, user)
     |> update_with_append(), temporary_assigns: [repositories: []]}
  end

  @impl true
  def handle_event("organization_selected", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: ~p"/settings/repos/#{id}")}
  end

  @impl true
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

  @impl true
  def handle_params(%{"organization_id" => id}, _uri, socket) do
    {:noreply, update_selected(socket, id)}
  end

  defp put_assigns(socket, %{"token" => token}, user) do
    provider = user.provider

    with {:ok, result} <- Network.organizations(token, provider, @orga_limit) do
      {orga_page_info, organizations} = result

      organization = %Organization{
        id: user.username,
        name: user.name,
        avatar_url: user.avatar_url
      }

      organizations = [organization | organizations]

      projects = Submissions.list_projects(user)

      assign(socket, %{
        page: 1,
        provider: provider,
        username: user.username,
        projects: projects,
        organizations: organizations,
        orga_page_info: orga_page_info
      })
    else
      {:error, _} ->
        handle_auth_failure(socket)
    end
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
    token = verify_value(token, provider)

    with {:ok, result} <- Network.user_repos(token, provider, @repo_limit, after_cursor) do
      {page_info, repos} = result
      update_repos(socket, repos, page_info)
    else
      {:error, _} ->
        handle_auth_failure(socket)
    end
  end

  defp load_repos(socket, organisation_id, after_cursor) do
    %{token: token, provider: provider} = socket.assigns
    token = verify_value(token, provider)

    with {:ok, result} <-
           Network.repos(token, provider, organisation_id, @repo_limit, after_cursor) do
      {page_info, repos} = result
      update_repos(socket, repos, page_info)
    else
      {:error, _} ->
        handle_auth_failure(socket)
    end
  end

  defp update_repos(socket, repos, page_info) do
    socket
    |> assign(repo_page_info: page_info)
    |> Phoenix.LiveView.Utils.force_assign(:repositories, repos)
  end
end
