defmodule AdoptopossWeb.Plugs.CurrentUser do
  @moduledoc """
  Plug for assigning a current user when the user is logged in.
  """

  import Plug.Conn

  def init(opts), do: opts

  @doc """
  Assign a :current_user to conn if there is one available in the session.
  """
  def call(%Plug.Conn{} = conn, _opts) do
    user = get_session(conn, :current_user)
    Plug.Conn.assign(conn, :current_user, user)
  end
end
