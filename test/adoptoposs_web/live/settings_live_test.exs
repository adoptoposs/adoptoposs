defmodule AdoptopossWeb.SettingsLiveTest do
  use AdoptopossWeb.LiveCase

  alias AdoptopossWeb.SettingsLive

  test "disconnected mount of /settings when logged out", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, SettingsLive))
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "connected mount of /settings when logged out", %{conn: conn} do
    {:error, %{redirect: %{to: "/"}}} = live(conn, Routes.live_path(conn, SettingsLive))
  end

  @tag login_as: "user123"
  test "disconnected mount of /settings when logged in", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, SettingsLive))
    assert html_response(conn, 200) =~ "Settings"
  end

  @tag login_as: "user123"
  test "connected mount of /settings when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, SettingsLive))
    assert html =~ "Settings"
  end
end
