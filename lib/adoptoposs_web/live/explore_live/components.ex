defmodule AdoptopossWeb.ExploreLive.Components do
  use AdoptopossWeb, :component

  attr :id, :string, required: true
  attr :filter_selection_open, :boolean, default: false
  attr :filters, :list, default: []
  attr :user_id, :string, required: true
  attr :subscribed_tags, :list, default: []
  attr :suggested_tags, :list, default: []
  attr :selected_filters, :list, default: []
  attr :tags, :list, default: []
  attr :custom_tags, :list, default: []
  attr :tag_query, :string, default: ""
  attr :tag_results, :list, default: []

  def dropdown_filters(assigns) do
    ~H"""
    <details class="w-full mt-2" open={if @filter_selection_open, do: "open"}>
      <summary class="pl-1 mt-2 text-left text-red-400 hover:text-red-400 border-gray-200 w-full">
        <div class="inline">
          <div class="inline-flex items-center">
            <i class="fa-solid fa-filter mr-1 text-base"></i>
            Set language filters (<%= Enum.count(@filters) %>)
          </div>

          <%= if Enum.any?(@filters) do %>
            <div class="inline float-right">
              <button class="button-link button-link--inline leading-none" phx-click="clear_filters">
                clear all <i class="fa-solid fa-xmark ml-1.5"></i>
              </button>
            </div>
          <% end %>
        </div>
      </summary>

      <div class="relative">
        <!-- Subscribed languages filters -->
        <div class="bg-gray-200 rounded-sm px-4 py-2 mt-4 font-bold">
          Your favorite languages
          <%= if @user_id do %>
            <span class="float-right">
              <.link navigate={~p"/settings"}>
                Edit
              </.link>
            </span>
          <% end %>
        </div>

        <div class="py-4">
          <.subscribed_filters
            id={"#{@id}-subscribed"}
            user_id={@user_id}
            tags={@subscribed_tags}
            suggested_tags={@suggested_tags}
            filters={@selected_filters}
            add_event="select_filter"
            remove_event="unselect_filter"
            phx_target={@id}
          />
        </div>

        <div class="bg-gray-200 rounded-sm px-4 py-2 font-bold">
          Top 10 languages
        </div>

        <div class="py-4">
          <.top_ten_filters
            id={"#{@id}-top-ten"}
            tags={Enum.take(@tags, 10)}
            filters={@selected_filters}
            add_event="select_filter"
            remove_event="unselect_filter"
            phx_target={@id}
          />
        </div>

        <div class="bg-gray-200 rounded-sm px-4 py-2 font-bold">
          Search to add language
        </div>

        <div class="py-4">
          <.searchable_filters
            id={"#{@id}-searchable"}
            tags={@custom_tags}
            filters={@selected_filters}
            add_event="select_filter"
            remove_event="unselect_filter"
            search_event="search"
            query={@tag_query}
            search_results={@tag_results}
            phx_target={@id}
          />
        </div>

        <div class="flex justify-center p-2 py-0">
          <button class="block mt-0" phx-click="apply_filters" phx-target={"##{@id}"}>
            Apply filters
          </button>
        </div>
      </div>
    </details>
    """
  end

  attr :id, :string, required: true
  attr :filter_selection_open, :boolean, default: false
  attr :filters, :list, default: []
  attr :user_id, :string, required: true
  attr :subscribed_tags, :list, default: []
  attr :suggested_tags, :list, default: []
  attr :selected_filters, :list, default: []
  attr :tags, :list, default: []
  attr :custom_tags, :list, default: []
  attr :tag_query, :string, default: ""
  attr :tag_results, :list, default: []

  def sidebar_filters(assigns) do
    ~H"""
    <div class="block">
      <h3>
        <i class="fa-solid fa-filter mr-1 text-base"></i> Project Filters
      </h3>
      <!-- Subscribed languages filters -->
      <p class="mt-6 px-4 py-2 bg-gray-200 font-bold rounded-sm">
        Your favorite languages
        <%= if @user_id do %>
          <span class="float-right">
            <.link navigate={~p"/settings"}>
              Edit
            </.link>
          </span>
        <% end %>
      </p>

      <.subscribed_filters
        id={"#{@id}-subscribed"}
        user_id={@user_id}
        tags={@subscribed_tags}
        suggested_tags={@suggested_tags}
        filters={@filters}
        add_event="add_filter"
        remove_event="remove_filter"
        phx_target={@id}
      />
      <!-- Top 10 language filters -->
      <p class="mt-6 px-4 py-2 bg-gray-200 font-bold rounded-sm">
        Top 10 languages
      </p>

      <.top_ten_filters
        id={"#{@id}-top-ten"}
        tags={Enum.take(@tags, 10)}
        filters={@filters}
        add_event="add_filter"
        remove_event="remove_filter"
        phx_target={@id}
      />
      <!-- Searchable filters -->
      <p class="mt-6 px-4 py-2 bg-gray-200 font-bold rounded-sm">
        Search to add language
      </p>

      <.searchable_filters
        id={"#{@id}-searchable"}
        tags={@custom_tags}
        filters={@filters}
        add_event="add_filter"
        remove_event="remove_filter"
        search_event="search"
        query={@tag_query}
        search_results={@tag_results}
        phx_target={@id}
      />
    </div>
    """
  end

  attr :id, :string, required: true
  attr :user_id, :string, required: true
  attr :tags, :list, default: []
  attr :suggested_tags, :list, default: []
  attr :filters, :list, default: []
  attr :add_event, :string, required: true
  attr :remove_event, :string, required: true
  attr :phx_target, :string, required: true

  def subscribed_filters(assigns) do
    ~H"""
    <%= if Enum.any?(@tags) do %>
      <div class="flex flex-row flex-wrap">
        <%= for {tag, project_count} <- @tags do %>
          <div class="mr-2 mb-2">
            <%= if project_count > 0 do %>
              <button
                id={"#{@id}-btn-toggle-#{tag.id}"}
                class="plain p-0"
                phx-click={if to_string(tag.id) in @filters, do: @remove_event, else: @add_event}
                phx-value-tag_id={tag.id}
                phx-target={"##{@phx_target}"}
              >
                <%= render(AdoptopossWeb.SharedView, "language_tag.html",
                  name: tag.name,
                  color: tag.color,
                  title: AdoptopossWeb.SharedView.count("project", count: project_count),
                  class:
                    "p-3 py-1 border rounded-sm cursor-pointer #{if to_string(tag.id) in @filters, do: "text-white bg-red-400 border-white hover:text-white hover:bg-red-400 hover:border-white", else: "border-gray-300 hover:bg-gray-200"}"
                ) %>
              </button>
            <% else %>
              <%= render(AdoptopossWeb.SharedView, "language_tag.html",
                name: tag.name,
                color: Adoptoposs.Tags.Tag.Utility.unknown().color,
                title: AdoptopossWeb.SharedView.count("project", count: project_count),
                class:
                  "p-3 py-1 border rounded-sm cursor-default bg-gray-100 text-gray-400 border-gray-300"
              ) %>
            <% end %>
          </div>
        <% end %>
      </div>
    <% else %>
      <div class="flex flex-col">
        <%= if @user_id do %>
          <%= if Enum.any?(@suggested_tags) do %>
            <p class="mb-2">We found that you might be interested in</p>

            <div class="flex flex-row flex-wrap mb-2">
              <%= for tag <- @suggested_tags do %>
                <%= render(AdoptopossWeb.SharedView, "language_tag.html",
                  name: tag.name,
                  color: tag.color,
                  class: "px-1 py-1 mr-2 text-base"
                ) %>
              <% end %>
            </div>

            <p class="mb-0">
              <.link navigate={~p"/settings"}>
                Add your favorite languages
              </.link>
              in your settings.
              They will appear here as quick filters.
            </p>
          <% else %>
            <p class="mb-0">
              <i class="fa-solid fa-circle-info mr-1.5"></i>
              You can follow your favorite languages in <.link navigate={~p"/settings"}> your settings</.link>.
              They will appear here as quick filters.
            </p>
          <% end %>
        <% else %>
          <.link navigate={~p"/auth/github"} class="button-link text-center mb-2">
            <i class="fa-brands fa-github mr-1"></i> Log in with GitHub
          </.link>

          <p class="mb-0">
            …and add your favorite languages. They will appear here as quick filters.
          </p>
        <% end %>
      </div>
    <% end %>
    """
  end

  attr :id, :string, required: true
  attr :tags, :list, default: []
  attr :filters, :list, default: []
  attr :add_event, :string, required: true
  attr :remove_event, :string, required: true
  attr :phx_target, :string, required: true

  def top_ten_filters(assigns) do
    ~H"""
    <div class="flex flex-row flex-wrap">
      <div :for={{tag, project_count} <- @tags} class="mr-2 mb-2">
        <button
          id={"#{@id}-btn-toggle-#{tag.id}"}
          class="plain p-0"
          phx-click={if to_string(tag.id) in @filters, do: @remove_event, else: @add_event}
          }
          phx-value-tag_id={tag.id}
          phx-target={"##{@phx_target}"}
        >
          <%= render(AdoptopossWeb.SharedView, "language_tag.html",
            name: tag.name,
            color: tag.color,
            title: AdoptopossWeb.SharedView.count("project", count: project_count),
            class:
              "p-3 py-1 border rounded-sm cursor-pointer #{if to_string(tag.id) in @filters, do: "text-white bg-red-400 border-white hover:text-white hover:bg-red-400 hover:border-white", else: "border-gray-300 hover:bg-gray-200"}"
          ) %>
        </button>
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :tags, :list, default: []
  attr :filters, :list, default: []
  attr :add_event, :string, required: true
  attr :remove_event, :string, required: true
  attr :search_event, :string, required: true
  attr :query, :string, default: ""
  attr :search_results, :list, default: []
  attr :phx_target, :string, required: true

  def searchable_filters(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row flex-wrap">
        <%= for {tag, project_count} <- @tags do %>
          <div class="mr-2 mb-2">
            <button
              id={"#{@id}-btn-remove-#{tag.id}"}
              class="plain p-0"
              phx-click={@remove_event}
              phx-value-tag_id={tag.id}
              phx-target={"##{@phx_target}"}
            >
              <%= render(AdoptopossWeb.SharedView, "language_tag.html",
                name: tag.name,
                color: tag.color,
                removeable: true,
                title: AdoptopossWeb.SharedView.count("project", count: project_count),
                class:
                  "p-3 py-1 border rounded-sm cursor-pointer text-white bg-red-400 border-white hover:text-white hover:bg-red-400 hover:border-white"
              ) %>
            </button>
          </div>
        <% end %>
      </div>

      <div class="flex items-center mt-2">
        <form
          id={"#{@id}-form"}
          class="inline-flex w-full"
          phx-submit={@search_event}
          phx-change={@search_event}
          phx-target={"##{@phx_target}"}
        >
          <input
            type="text"
            class="search grow border h-12 pl-6 pr-10"
            id={"#{@id}-tag_search"}
            name="q"
            value={@query}
            autocomplete="off"
            placeholder="Search for languages"
            phx-debounce="200"
          />
        </form>

        <%= unless @query in [nil, ""] do %>
          <button
            class="button-link button-link--inline indented-sm w-5 h-5"
            phx-click="clear_search"
            phx-target={"##{@phx_target}"}
          >
            <i class="fa-solid fa-xmark"></i>
          </button>
        <% end %>
      </div>

      <div class="flex flex-row flex-wrap mt-4 md:mt-4">
        <%= if @query && Enum.empty?(@search_results) do %>
          <p class="text-pink-900">
            No language found for <span class="text-red-400 break-all">"<%= @query %>"</span> :(
          </p>
        <% else %>
          <%= for {tag, project_count} <- @search_results do %>
            <div class="mr-2 mb-2">
              <%= if project_count > 0  && to_string(tag.id) not in @filters do %>
                <button
                  id={"#{@id}-btn-add-#{tag.id}"}
                  class="plain p-0"
                  phx-click={@add_event}
                  phx-value-tag_id={tag.id}
                  phx-target={"##{@phx_target}"}
                >
                  <%= render(AdoptopossWeb.SharedView, "language_tag.html",
                    name: tag.name,
                    color: tag.color,
                    title: AdoptopossWeb.SharedView.count("project", count: project_count),
                    class:
                      "p-3 py-1 border rounded-sm cursor-pointer border-gray-300 hover:bg-gray-200"
                  ) %>
                </button>
              <% else %>
                <%= render(AdoptopossWeb.SharedView, "language_tag.html",
                  name: tag.name,
                  title: AdoptopossWeb.SharedView.count("project", count: project_count),
                  color: Adoptoposs.Tags.Tag.Utility.unknown().color,
                  class:
                    "p-3 py-1 border rounded-sm cursor-default bg-gray-100 text-gray-400 border-gray-300"
                ) %>
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
