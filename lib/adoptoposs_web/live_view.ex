defmodule AdoptopossWeb.LiveView do
  @moduledoc """
  Basic module for Adoptoposs live views.
  """

  defmodule Authenticatable do
    @type unsigned_params :: map

    @callback mount_logged_in(
                unsigned_params() | :not_mounted_at_router,
                session :: map,
                socket :: Socket.t()
              ) ::
                {:ok, Socket.t()} | {:ok, Socket.t(), keyword()}

    @callback mount_logged_out(
                unsigned_params() | :not_mounted_at_router,
                session :: map,
                socket :: Socket.t()
              ) ::
                {:ok, Socket.t()} | {:ok, Socket.t(), keyword()}

    @optional_callbacks mount_logged_in: 3, mount_logged_out: 3
  end

  defmacro __using__(_opts) do
    quote do
      use Phoenix.LiveView, layout: {AdoptopossWeb.LayoutView, "live.html"}
      use AdoptopossWeb.LiveHelpers

      alias Adoptoposs.Accounts.User
      alias Adoptoposs.Communication

      @behaviour Authenticatable

      @impl true
      def mount(params, %{"user_id" => user_id} = session, socket) when not is_nil(user_id) do
        socket = assign_notification_count(socket, user_id)
        apply(__MODULE__, :mount_logged_in, [params, session, socket])
      end

      @impl true
      def mount(params, session, socket) do
        apply(__MODULE__, :mount_logged_out, [params, session, socket])
      end

      defp assign_notification_count(socket, user_id) do
        assign(socket, notification_count: Communication.count_notifications(user_id))
      end
    end
  end
end
