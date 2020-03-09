defmodule AdoptopossWeb.SettingsLive do
  use AdoptopossWeb, :live_view

  alias AdoptopossWeb.SettingsView
  alias Adoptoposs.{Accounts, Tags, Search}

  @per_page 20

  def render(assigns) do
    Phoenix.View.render(SettingsView, "index.html", assigns)
  end

  def mount(_params, %{"user_id" => user_id} = session, socket) do
    user = Accounts.get_user!(user_id)

    {:ok,
     socket
     |> assign_user(session)
     |> assign_settings(user)
     |> assign_tag_subscriptions(user)
     |> assign(query: nil, page: 1)
     |> update_with_append(), temporary_assigns: [tag_results: []]}
  end

  def handle_event("search_tags", %{"q" => query}, %{assigns: assigns} = socket) do
    query = String.trim(query)
    previous_query = assigns.query

    cond do
      query == previous_query ->
        {:noreply, assign(socket, query: query)}

      query == "" ->
        {:noreply,
         socket
         |> assign(query: nil, tag_results: [])
         |> update_with_replace()}

      true ->
        {:noreply,
         socket
         |> assign(page: 1)
         |> update_with_replace()
         |> search_tags(query)}
    end
  end

  def handle_event("follow_tag", %{"tag_id" => id}, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    tag = Tags.get_tag!(id)
    attrs = %{user_id: user.id, tag_id: tag.id}

    case Tags.create_tag_subscription(attrs) do
      {:ok, _tag_subscription} ->
        {:noreply,
         socket
         |> assign_tag_subscriptions(user)
         |> search_tags(socket.assigns.query)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("unfollow_tag", %{"tag_subscription_id" => id}, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    tag_subscription = Tags.get_tag_subscription!(id)

    case Tags.delete_tag_subscription(tag_subscription) do
      {:ok, _tag_subscription} ->
        {:noreply,
         socket
         |> assign_tag_subscriptions(user)
         |> search_tags(socket.assigns.query)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("update_settings", %{"user" => %{"settings" => settings}}, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)

    case Accounts.update_settings(user, settings) do
      {:ok, updated_user} ->
        {:noreply, assign_settings(socket, updated_user)}

      {:error, changeset} ->
        {:noreply, assign(socket, settings: changeset)}
    end
  end

  defp assign_settings(socket, user) do
    assign(socket, settings: Accounts.change_settings(user))
  end

  defp assign_tag_subscriptions(socket, user) do
    assign(socket, tag_subscriptions: Tags.list_user_tag_subscriptions(user))
  end

  defp search_tags(socket, ""), do: socket
  defp search_tags(socket, nil), do: socket

  defp search_tags(socket, query) do
    offset = (socket.assigns.page - 1) * @per_page
    tags = Search.find_tags(query, offset: offset, limit: @per_page)

    assign(socket, query: query, tag_results: tags)
  end
end
