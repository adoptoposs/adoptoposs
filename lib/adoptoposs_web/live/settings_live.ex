defmodule AdoptopossWeb.SettingsLive do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.SettingsView
  alias Adoptoposs.{Accounts, Tags, Search}

  @tag_results_count 20

  @impl true
  def render(assigns) do
    Phoenix.View.render(SettingsView, "index.html", assigns)
  end

  @impl true
  def mount(_params, %{"user_id" => user_id} = session, socket) do
    user = Accounts.get_user!(user_id, preload: [tag_subscriptions: [:tag]])

    {:ok,
     socket
     |> assign_user(session)
     |> assign_token(session, user.provider)
     |> assign_settings(user)
     |> assign_tag_subscriptions(user)
     |> assign(query: nil, tag_results: [])}
  end

  @impl true
  def handle_event("search_tags", %{"q" => query}, %{assigns: assigns} = socket) do
    query = String.trim(query)
    previous_query = assigns.query

    case query do
      ^previous_query ->
        {:noreply, assign(socket, query: query)}

      "" ->
        {:noreply, assign(socket, query: nil, tag_results: [])}

      _ ->
        {:noreply, search_tags(socket, query)}
    end
  end

  @impl true
  def handle_event("clear_search", _, socket) do
    {:noreply, assign(socket, query: nil, tag_results: [])}
  end

  @impl true
  def handle_event("add_tag", %{"tag_id" => id}, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    tag = Tags.get_tag!(id)
    attrs = %{user_id: user.id, tag_id: tag.id}

    with :ok <- Bodyguard.permit(Tags, :create_tag_subscription, user, tag),
         {:ok, _tag_subscription} <- Tags.create_tag_subscription(attrs) do
      {:noreply,
       socket
       |> assign_tag_subscriptions(user)
       |> search_tags(socket.assigns.query)}
    else
      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("add_suggested_tags", _params, %{assigns: assigns} = socket) do
    user = Accounts.get_user!(assigns.user_id)
    tags = assigns.suggested_tags
    attrs = tags |> Enum.map(&%{user_id: user.id, tag_id: &1.id})

    Tags.create_tag_subscriptions(attrs)
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__))}
  end

  @impl true
  def handle_event("remove_tag", %{"tag_subscription_id" => id}, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    tag_subscription = Tags.get_tag_subscription!(id)

    with :ok <- Bodyguard.permit(Tags, :delete_tag_subscription, user, tag_subscription),
         {:ok, _tag_subscription} <- Tags.delete_tag_subscription(tag_subscription) do
      {:noreply,
       socket
       |> assign_tag_subscriptions(user)
       |> search_tags(socket.assigns.query)}
    else
      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update_settings", %{"user" => %{"settings" => settings}}, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)

    case Accounts.update_settings(user, settings) do
      {:ok, updated_user} ->
        {:noreply, assign_settings(socket, updated_user)}

      {:error, _changeset} ->
        {:noreply, assign(socket, settings: Accounts.change_settings(user))}
    end
  end

  defp assign_settings(socket, user) do
    assign(socket, settings: Accounts.change_settings(user))
  end

  defp assign_tag_subscriptions(
         socket,
         %{tag_subscriptions: %Ecto.Association.NotLoaded{}} = user
       ) do
    tag_subscriptions = Tags.list_user_tag_subscriptions(user)
    user = Map.put(user, :tag_subscriptions, tag_subscriptions)
    assign_tag_subscriptions(socket, user)
  end

  defp assign_tag_subscriptions(socket, %{tag_subscriptions: subscriptions} = user)
       when length(subscriptions) == 0 do
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
  end

  defp assign_tag_subscriptions(socket, user) do
    assign(socket,
      tag_subscriptions: user.tag_subscriptions,
      suggested_tags: []
    )
  end

  defp search_tags(socket, ""), do: socket
  defp search_tags(socket, nil), do: socket

  defp search_tags(socket, query) do
    tags = Search.find_tags(query, offset: 0, limit: @tag_results_count)
    assign(socket, query: query, tag_results: tags)
  end
end
