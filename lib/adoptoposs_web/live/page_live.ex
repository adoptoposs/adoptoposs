defmodule AdoptopossWeb.PageLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Dashboard, Tags}
  alias AdoptopossWeb.PageView

  @doc """
  Renders the logged out landing page template.
  """
  def render(%{user_id: nil} = assigns) do
    Phoenix.View.render(PageView, "index.html", assigns)
  end

  @doc """
  Renders the logged-in user's dashbard template.
  """
  def render(assigns) do
    Phoenix.View.render(PageView, "dashboard.html", assigns)
  end

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_user(session)
     |> put_assigns(session)}
  end

  defp put_assigns(socket, %{"current_user" => user}) do
    assign(socket,
      projects: Dashboard.list_projects(limit: 6),
      tags: Tags.list_user_tag_subscriptions(user) |> Enum.map(& &1.tag)
    )
  end

  defp put_assigns(socket, _) do
    assign(socket, projects: Dashboard.list_projects(limit: 6))
  end

  defp assign_user(socket, %{"current_user" => user}) do
    assign(socket, user_id: user.id)
  end

  defp assign_user(socket, _) do
    assign(socket, user_id: nil)
  end
end
