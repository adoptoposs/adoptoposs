defmodule AdoptopossWeb.ExploreLive do
  use AdoptopossWeb, :live_view

  alias Adoptoposs.{Search, Accounts, Tags}
  alias AdoptopossWeb.ExploreView

  @per_page 16

  @impl true
  def render(assigns) do
    Phoenix.View.render(ExploreView, "index.html", assigns)
  end

  @impl true
  def mount(_params, %{"user_id" => user_id} = session, socket) when not is_nil(user_id) do
    user = Accounts.get_user!(user_id, preload: [tag_subscriptions: [:tag]])

    {:ok,
     socket
     |> assign_token(session, user.provider)
     |> assign_defaults(session, user: user), temporary_assigns: [projects: []]}
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session), temporary_assigns: [projects: []]}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    query = String.trim(params["q"] || "")
    filters = Enum.uniq(params["f"] || [])

    {:noreply,
     socket
     |> assign(page: 1)
     |> update_with_replace()
     |> search(query: query, filters: filters)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, %{assigns: assigns} = socket) do
    query = String.trim(query)
    previous_query = assigns.query

    if query == previous_query do
      {:noreply, assign(socket, query: query)}
    else
      {:noreply, set_params(socket, q: query, f: assigns.filters)}
    end
  end

  @impl true
  def handle_event("load_more", _, %{assigns: assigns} = socket) do
    %{query: query, filters: filters, page: page} = assigns

    {:noreply,
     socket
     |> assign(page: page + 1)
     |> update_with_append()
     |> search(query: query, filters: filters)}
  end

  @impl true
  def handle_event("clear_filters", _, %{assigns: assigns} = socket) do
    {:noreply, set_params(socket, q: assigns.query, f: [])}
  end

  @impl true
  def handle_event("clear_search", _, %{assigns: assigns} = socket) do
    {:noreply, set_params(socket, f: assigns.filters)}
  end

  @impl true
  def handle_info({:apply_filters, filters, _opts}, %{assigns: assigns} = socket) do
    {:noreply, set_params(socket, q: assigns.query, f: filters)}
  end

  @impl true
  def handle_info({:force_update}, %{assigns: assigns} = socket) do
    opts = %{q: assigns.query, f: assigns.filters}
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, __MODULE__, opts))}
  end

  defp set_params(socket, opts) do
    push_patch(socket, to: Routes.live_path(socket, __MODULE__, opts))
  end

  defp assign_defaults(socket, session, opts \\ []) do
    socket
    |> assign_user(session)
    |> assign(page: 1)
    |> assign_project_tags()
    |> assign_subscribed_tags(opts[:user])
    |> search(query: nil, filters: [])
    |> update_with_append()
  end

  defp assign_project_tags(socket) do
    assign(socket, tags: Tags.list_published_project_tags())
  end

  defp assign_subscribed_tags(%{assigns: assigns} = socket, user) when not is_nil(user) do
    if Enum.empty?(user.tag_subscriptions) do
      token = verify_value(assigns.token, user.provider)

      with {:ok, tags} <- Tags.list_recommended_tags(user, token) do
        assign(socket,
          subscribed_tags: [],
          suggested_tags: tags
        )
      else
        {:error, _} ->
          handle_auth_failure(socket)
      end
    else
      tags =
        Enum.map(user.tag_subscriptions, fn tag_subscription ->
          tag = tag_subscription.tag
          assigns.tags |> Enum.find(&match?({^tag, _}, &1)) || {tag, 0}
        end)

      assign(socket,
        subscribed_tags: tags,
        suggested_tags: []
      )
    end
  end

  defp assign_subscribed_tags(socket, _user) do
    assign(socket, subscribed_tags: [], suggested_tags: [])
  end

  defp search(socket, query: query, filters: filters) do
    offset = (socket.assigns.page - 1) * @per_page

    %{results: projects, total_count: total_count} =
      Search.find_projects(query, offset: offset, limit: @per_page, filters: filters)

    assign(socket,
      query: query,
      filters: filters,
      projects: projects,
      total_count: total_count
    )
  end
end
