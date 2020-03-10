defmodule AdoptopossWeb.LiveView do
  @moduledoc """
  Basic module for Adoptoposs live views.
  """

  defmacro __using__(_opts) do
    quote do
      use Phoenix.LiveView, layout: {AdoptopossWeb.LayoutView, "live.html"}

      defp assign_user(socket, %{"user_id" => user_id}) do
        assign(socket, user_id: user_id)
      end

      defp assign_user(socket, _) do
        assign(socket, user_id: nil)
      end

      defp update_with_append(socket) do
        assign(socket, update: "append")
      end

      defp update_with_replace(socket) do
        assign(socket, update: "replace")
      end
    end
  end
end
