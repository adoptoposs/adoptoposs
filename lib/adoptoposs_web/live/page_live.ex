defmodule AdoptopossWeb.PageLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Dashboard, Accounts}
  alias AdoptopossWeb.PageView

  def render(assigns) do
    Phoenix.View.render(PageView, "index.html", assigns)
  end

  def mount(_params, session, socket) do
    projects = Dashboard.list_projects(limit: 6)

    {:ok,
     assign(socket,
       user_id: get_user_id(socket),
       projects: projects
     )}
  end

  defp get_user_id(%{"current_user" => user}), do: user.id
  defp get_user_id(_), do: nil
end
