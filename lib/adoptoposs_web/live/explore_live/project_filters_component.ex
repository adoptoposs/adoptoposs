defmodule AdoptopossWeb.ProjectFiltersComponent do
  use AdoptopossWeb, :live_component

  import AdoptopossWeb.ExploreLive.Components

  alias Adoptoposs.Search

  @top_tags_count 10
  @tag_search_limit 12

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} phx-target={@myself}>
      <%= if @dropdown do %>
        <.dropdown_filters
          id={@id}
          filter_selection_open={@filter_selection_open}
          filters={@filters}
          user_id={@user_id}
          subscribed_tags={@subscribed_tags}
          suggested_tags={@suggested_tags}
          custom_tags={@selected_custom_tags}
          selected_filters={@selected_filters}
          tags={@tags}
          tag_query={@tag_query}
          tag_results={@tag_results}
        />
      <% else %>
        <.sidebar_filters
          id={@id}
          filter_selection_open={@filter_selection_open}
          filters={@filters}
          user_id={@user_id}
          subscribed_tags={@subscribed_tags}
          suggested_tags={@suggested_tags}
          custom_tags={@selected_custom_tags}
          selected_filters={@selected_filters}
          tags={@tags}
          tag_query={@tag_query}
          tag_results={@tag_results}
        />
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(tag_query: nil, tag_results: [])
     |> assign(custom_filters: [], custom_tags: [])
     |> assign(selected_filters: [], selected_custom_tags: [], filter_selection_open: false)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, update_assigns(socket, assigns)}
  end

  @impl true
  def handle_event("add_filter", %{"tag_id" => tag_id}, %{assigns: assigns} = socket) do
    filters = [to_string(tag_id) | assigns.filters] |> Enum.uniq()
    apply_filters(filters)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_filter", %{"tag_id" => tag_id}, %{assigns: assigns} = socket) do
    filters = List.delete(assigns.filters, to_string(tag_id))
    apply_filters(filters)
    {:noreply, socket}
  end

  @impl true
  def handle_event("select_filter", %{"tag_id" => tag_id}, %{assigns: assigns} = socket) do
    selected_filters = [to_string(tag_id) | assigns.selected_filters] |> Enum.uniq()
    tag = Enum.find(assigns.tag_results, &(to_string(elem(&1, 0).id) == tag_id))

    selected_custom_tags =
      if is_nil(tag) do
        assigns.selected_custom_tags
      else
        top_tags = Enum.take(assigns.tags, @top_tags_count)
        skip_tag = tag in (top_tags ++ assigns.subscribed_tags)

        old_tags = assigns.selected_custom_tags
        if skip_tag, do: old_tags, else: [tag | old_tags] |> Enum.uniq()
      end

    {:noreply,
     assign(
       socket,
       selected_filters: selected_filters,
       selected_custom_tags: selected_custom_tags,
       filter_selection_open: true
     )}
  end

  @impl true
  def handle_event("unselect_filter", %{"tag_id" => tag_id}, %{assigns: assigns} = socket) do
    custom_tags = (assigns.selected_custom_tags ++ assigns.custom_tags) |> Enum.uniq()
    tag = Enum.find(custom_tags, &(to_string(elem(&1, 0).id) == tag_id))

    selected_filters = List.delete(assigns.selected_filters, to_string(tag_id))
    selected_custom_tags = List.delete(assigns.selected_custom_tags, tag)

    {:noreply,
     assign(
       socket,
       selected_filters: selected_filters,
       selected_custom_tags: selected_custom_tags,
       filter_selection_open: true
     )}
  end

  @impl true
  def handle_event("apply_filters", _, %{assigns: assigns} = socket) do
    apply_filters(assigns.selected_filters)
    {:noreply, assign(socket, tag_query: nil, tag_results: [])}
  end

  @impl true
  def handle_event("search", %{"q" => query}, %{assigns: assigns} = socket) do
    query = String.trim(query)
    previous_query = assigns.tag_query
    socket = assign(socket, filter_selection_open: true)

    case query do
      ^previous_query ->
        {:noreply, assign(socket, tag_query: query)}

      "" ->
        {:noreply, assign(socket, tag_query: nil, tag_results: [])}

      _ ->
        {:noreply, search_tags(socket, query)}
    end
  end

  @impl true
  def handle_event("clear_search", _, socket) do
    {:noreply, assign(socket, tag_query: nil, tag_results: [])}
  end

  defp update_assigns(socket, assigns) do
    assigns =
      assigns
      |> Map.take([:id, :dropdown, :user_id, :subscribed_tags, :suggested_tags, :filters, :tags])

    %{filters: filters, tags: tags, subscribed_tags: subscribed_tags} = assigns

    top_tags = Enum.take(tags, @top_tags_count)
    top_tag_filters = Enum.map(top_tags, &to_string(elem(&1, 0).id))
    subscribed_tag_filters = Enum.map(subscribed_tags, &to_string(elem(&1, 0).id))
    custom_filters = filters -- (top_tag_filters ++ subscribed_tag_filters)
    custom_tags = Enum.filter(tags, &(to_string(elem(&1, 0).id) in custom_filters))

    new_assigns = %{
      selected_filters: filters,
      custom_filters: custom_filters,
      custom_tags: custom_tags,
      selected_custom_tags: custom_tags,
      filter_selection_open: false
    }

    assign(socket, Map.merge(assigns, new_assigns))
  end

  defp apply_filters(filters, opts \\ []) do
    send(self(), {:apply_filters, filters, opts})
  end

  defp search_tags(socket, ""), do: socket
  defp search_tags(socket, nil), do: socket

  defp search_tags(%{assigns: assigns} = socket, query) do
    tags =
      query
      |> Search.find_tags(offset: 0, limit: @tag_search_limit)
      |> Enum.map(fn tag ->
        assigns.tags |> Enum.find(&match?({^tag, _}, &1)) || {tag, 0}
      end)

    assign(socket, tag_query: query, tag_results: tags)
  end
end
