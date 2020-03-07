defmodule AdoptopossWeb.Plugs.CurrentUser do
  @moduledoc """
  Plug for assigning a current user when the user is logged in.
  """

  import Plug.Conn

  alias Adoptoposs.Accounts

  def init(opts), do: opts

  @doc """
  Assign a :current_user to conn if there is a user_id available in the session.
  """
  def call(%Plug.Conn{} = conn, _opts) do
    Plug.Conn.assign(conn, :current_user, get_user(conn))
  end

  defp get_user(conn) do
    case get_session(conn, :user_id) do
      nil -> nil
      user_id -> Accounts.get_user(user_id)
    end
  end
end
