defmodule AdoptopossWeb.LandingPageLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Accounts, Submissions, Communication, Tags}
  alias Adoptoposs.Accounts.User
  alias AdoptopossWeb.LandingPageView

  @recommendations_limit 5
  @latest_projects_limit 5

  @impl true
  def render(%{user_id: user_id} = assigns) when not is_nil(user_id) do
    Phoenix.View.render(LandingPageView, "dashboard.html", assigns)
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(LandingPageView, "index.html", assigns)
  end

  @impl true
  def mount_logged_in(_params, %{"user_id" => user_id} = session, socket) do
    user = Accounts.get_user!(user_id, preload: [tag_subscriptions: [:tag]])

    {:ok,
     socket
     |> assign_user(session)
     |> assign_token(session, user.provider)
     |> put_assigns(user)}
  end

  @impl true
  def mount_logged_out(_params, _session, socket) do
    {:ok, put_projects(socket)}
  end

  @impl true
  def handle_params(%{"f" => tag_name}, _uri, %{assigns: %{user_id: user_id}} = socket) do
    user = %User{id: user_id}
    tag_subscriptions = socket.assigns[:tag_subscriptions]
    tag = find_tag_by_name(tag_subscriptions, tag_name)

    socket |> apply_tag_filter(user, tag)
  end

  @impl true
  def handle_params(_params, _uri, %{assigns: %{tag_subscriptions: tag_subscriptions}} = socket) do
    user = %User{id: socket.assigns.user_id}
    tag = first_tag(tag_subscriptions)
    {:noreply, socket |> put_recommendations(user, tag)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("filter_recommendations", %{"tag_subscription_id" => id}, socket) do
    tag = find_tag(socket.assigns.tag_subscriptions, id)
    {:noreply, socket |> push_tag_filter(tag)}
  end

  @impl true
  def handle_event("follow_suggested_tags", _params, %{assigns: assigns} = socket) do
    user = Accounts.get_user!(assigns.user_id)
    tags = assigns.suggested_tags
    attrs = tags |> Enum.map(&%{user_id: user.id, tag_id: &1.id})

    Tags.create_tag_subscriptions(attrs)
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
  end

  defp apply_tag_filter(socket, _user, nil) do
    tag = first_tag(socket.assigns[:tag_subscriptions])
    {:noreply, socket |> push_tag_filter(tag)}
  end

  defp apply_tag_filter(socket, user, tag) do
    {:noreply, socket |> put_recommendations(user, tag)}
  end

  defp push_tag_filter(socket, nil), do: socket

  defp push_tag_filter(socket, tag) do
    filter = String.downcase(tag.name)
    path = Routes.live_path(socket, __MODULE__, f: filter)
    push_patch(socket, to: path)
  end

  defp put_assigns(socket, %User{} = user) do
    socket
    |> put_tag_subsriptions(user)
    |> put_recommendations(user, nil)
  end

  defp put_projects(socket) do
    assign(socket, projects: Submissions.list_projects(limit: @latest_projects_limit))
  end

  defp put_tag_subsriptions(socket, user) do
    if Enum.empty?(user.tag_subscriptions) do
      token = verify_value(socket.assigns.token, user.provider)

      with {:ok, tags} <- Tags.list_recommended_tags(user, token) do
        assign(socket,
          tag_subscriptions: [],
          suggested_tags: tags
        )
      else
        {:error, _} ->
          handle_auth_failure(socket)
      end
    else
      assign(socket,
        tag_subscriptions: user.tag_subscriptions,
        suggested_tags: []
      )
    end
  end

  defp put_recommendations(socket, _user, nil) do
    assign(socket, recommendations: [], tag_filter: nil)
  end

  defp put_recommendations(socket, user, tag) do
    options = [limit: @recommendations_limit, preload: [:interests, :language, :user]]
    recommendations = Submissions.list_recommended_projects(user, tag, options)

    assign(socket, recommendations: recommendations, tag_filter: tag.id)
  end

  defp first_tag(nil), do: nil
  defp first_tag(tag_subscriptions) when length(tag_subscriptions) == 0, do: nil

  defp first_tag(tag_subscriptions) do
    List.first(tag_subscriptions).tag
  end

  defp find_tag(tag_subscriptions, id) do
    tag_subscription = Enum.find(tag_subscriptions, &(to_string(&1.id) == id))
    if tag_subscription, do: tag_subscription.tag, else: nil
  end

  defp find_tag_by_name(nil, _), do: nil
  defp find_tag_by_name(_, nil), do: nil
  defp find_tag_by_name(tag_subscriptions, _) when length(tag_subscriptions) == 0, do: nil

  defp find_tag_by_name(tag_subscriptions, name) do
    tag_subscription =
      Enum.find(
        tag_subscriptions,
        &(String.downcase(&1.tag.name) == String.downcase(name))
      )

    if tag_subscription, do: tag_subscription.tag, else: nil
  end
end
