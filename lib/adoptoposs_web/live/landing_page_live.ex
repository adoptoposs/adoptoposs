defmodule AdoptopossWeb.LandingPageLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Accounts, Submissions, Communication}
  alias AdoptopossWeb.LandingPageView

  @recommendations_limit 5

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

  def handle_event("filter_recommendations", %{"tag_subscription_id" => id}, socket) do
    user = %Accounts.User{id: socket.assigns.user_id}
    tag = find_tag(socket.assigns.tag_subscriptions, id)

    {:noreply, socket |> put_recommendations(user, tag)}
  end

  defp put_assigns(socket, %{"user_id" => user_id}) do
    user = Accounts.get_user!(user_id, preload: [tag_subscriptions: [:tag]])

    socket
    |> put_interests(user)
    |> assign(tag_subscriptions: user.tag_subscriptions)
    |> put_recommendations(user, first_tag(user.tag_subscriptions))
  end

  defp put_assigns(socket, _) do
    assign(socket, projects: Submissions.list_projects(limit: 6))
  end

  defp put_interests(socket, user) do
    assign(socket, interests: Communication.list_user_interests(user))
  end

  defp put_recommendations(socket, _user, nil) do
    assign(socket, recommendations: [], tag_filter: nil)
  end

  defp put_recommendations(socket, user, tag) do
    options = [limit: @recommendations_limit, preload: [:interests, :language, :user]]
    recommendations = Submissions.list_recommended_projects(user, tag, options)

    assign(socket, recommendations: recommendations, tag_filter: tag.id)
  end

  defp first_tag([]), do: nil

  defp first_tag(tag_subscriptions) do
    List.first(tag_subscriptions).tag
  end

  defp find_tag(tag_subscriptions, id) do
    tag_subscription = Enum.find(tag_subscriptions, &(to_string(&1.id) == id))
    if tag_subscription, do: tag_subscription.tag, else: nil
  end
end
