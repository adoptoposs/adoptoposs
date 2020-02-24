defmodule AdoptoppossWeb.Plugs.RequireLoginTest do
  use AdoptopossWeb.ConnCase

  alias Adoptoposs.Accounts.User
  alias AdoptopossWeb.Plugs.RequireLogin

  setup(%{conn: conn}) do
    conn =
      conn
      |> init_test_session(%{})
      |> fetch_flash()

    {:ok, %{conn: conn}}
  end

  test "user is redirected if current_user is not assigned", %{conn: conn} do
    conn = require_login(conn)

    assert redirected_to(conn) == Routes.live_path(conn, AdoptopossWeb.PageLive)
    assert get_flash(conn, :error) =~ "You need to log in"
    assert %{halted: true} = conn
  end

  test "user passes through if current_user is assigned", %{conn: conn} do
    conn =
      conn
      |> authenticate()
      |> require_login()

    assert conn.status != 302
    assert %{halted: false} = conn
  end

  defp authenticate(conn) do
    conn |> assign(:current_user, %User{})
  end

  defp require_login(conn) do
    conn |> RequireLogin.call(%{})
  end
end
