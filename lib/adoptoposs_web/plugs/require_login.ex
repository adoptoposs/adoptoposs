defmodule AdoptopossWeb.Plugs.RequireLogin do
  @moduledoc """
  Plug for redirecting the request when the user is not logged in.
  """

  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias AdoptopossWeb.Router.Helpers, as: Routes

  alias Adoptoposs.Accounts.User

  def init(opts), do: opts

  @doc """
  Passes through if user is logged in.
  Redirects to landing page if user is logged out.
  """
  def call(conn, opts)

  def call(%Plug.Conn{assigns: %{current_user: %User{}}} = conn, _opts) do
    conn
  end

  def call(conn, _opts) do
    conn
    |> put_flash(:error, "You need to log in to visit this page.")
    |> redirect(to: Routes.live_path(conn, AdoptopossWeb.LandingPageLive))
    |> halt()
  end
end
