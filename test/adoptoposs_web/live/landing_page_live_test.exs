defmodule AdoptopossWeb.LandingPageLiveTest do
  use AdoptopossWeb.LiveCase

  alias AdoptopossWeb.LandingPageLive

  test "disconnected mount when logged out", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, LandingPageLive))

    html = html_response(conn, 200)
    assert html =~ "Adoptoposs."
    refute html =~ "Your Dashboard"
  end

  test "disconnected mount when logged out with query params", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, LandingPageLive, f: "something"))

    html = html_response(conn, 200)
    assert html =~ "Adoptoposs."
    refute html =~ "Your Dashboard"
  end

  @tag login_as: "user123"
  test "disconnected mount when logged in", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, LandingPageLive))

    html = html_response(conn, 200)
    assert html =~ "Your Dashboard"
    refute html =~ "Adoptoposs."
  end

  test "connected mount when logged out", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, LandingPageLive))
    assert html =~ "Adoptoposs."
  end

  @tag login_as: "user123"
  test "connected mount when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, LandingPageLive))
    assert html =~ "Your Dashboard"
  end
end
