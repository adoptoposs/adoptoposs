defmodule AdoptopossWeb.LiveHelpers do
  @moduledoc """
  Helpers functions to be used in Adoptoposs live views and live components.
  """

  defmacro __using__(_opts) do
    quote do
      alias AdoptopossWeb.{Endpoint, Router}

      defp handle_auth_failure(socket) do
        logout_path = Router.Helpers.auth_path(Endpoint, :delete)
        redirect(socket, to: logout_path)
      end

      defp assign_user(socket, %{"user_id" => user_id}) do
        assign(socket, user_id: user_id)
      end

      defp assign_user(socket, _) do
        assign(socket, user_id: nil)
      end

      defp assign_token(socket, %{"token" => token}, salt) do
        assign(socket, token: sign_value(token, salt))
      end

      defp assign_token(socket, _, _) do
        assign(socket, token: nil)
      end

      defp update_with_append(socket) do
        assign(socket, update: "append")
      end

      defp update_with_replace(socket) do
        assign(socket, update: "replace")
      end

      defp sign_value(value, salt) do
        Phoenix.Token.sign(Endpoint, salt, value)
      end

      def verify_value(value, salt) do
        {:ok, value} = Phoenix.Token.verify(Endpoint, salt, value, max_age: 86400)
        value
      end
    end
  end
end
