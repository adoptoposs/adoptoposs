defmodule AdoptopossWeb.Plugs.PutNotificationCount do
  @moduledoc """
  Plug for putting a notification_count if the user is logged in.
  """

  import Plug.Conn

  alias Adoptoposs.Communication

  def init(opts), do: opts

  @doc """
  Assign a :notification_count to conn if there is a user_id available in the session.
  """
  def call(%Plug.Conn{} = conn, _opts) do
    assign(conn, :notification_count, notification_count(conn))
  end

  defp notification_count(conn) do
    case get_session(conn, :user_id) do
      nil -> nil
      user_id -> Communication.count_notifications(user_id)
    end
  end
end
