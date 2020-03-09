defmodule AdoptopossWeb.SearchLiveTest do
  use AdoptopossWeb.LiveCase

  test "disconnected mount of /search when logged out", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, AdoptopossWeb.SearchLive))
    assert html_response(conn, 200) =~ "Find projects"
  end

  test "connected mount of /search when logged out", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, AdoptopossWeb.SearchLive))
    assert html =~ "Find projects"
  end

  @tag login_as: "user123"
  test "disconnected mount of /search when logged in", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, AdoptopossWeb.SearchLive))
    assert html_response(conn, 200) =~ "Find projects"
  end

  @tag login_as: "user123"
  test "connected mount of /search when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, AdoptopossWeb.SearchLive))
    assert html =~ "Find projects"
  end
end
