defmodule AdoptopossWeb.LandingPageLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Accounts, Submissions, Communication}
  alias AdoptopossWeb.LandingPageView

  @doc """
  Renders the logged out landing page template.
  """
  def render(%{user_id: nil} = assigns) do
    Phoenix.View.render(LandingPageView, "index.html", assigns)
  end

  @doc """
  Renders the logged-in user's dashbard template.
  """
  def render(assigns) do
    Phoenix.View.render(LandingPageView, "dashboard.html", assigns)
  end

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_user(session)
     |> put_assigns(session)}
  end

  defp put_assigns(socket, %{"user_id" => user_id}) do
    interests =
      user_id
      |> Accounts.get_user!()
      |> Communication.list_user_interests()

    assign(socket, interests: interests)
  end

  defp put_assigns(socket, _) do
    assign(socket, projects: Submissions.list_projects(limit: 6))
  end
end
