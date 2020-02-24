defmodule AdoptopossWeb.SearchLiveTest do
  use AdoptopossWeb.ConnCase

  test "GET /search", %{conn: conn} do
    conn = get(conn, "/search")
    assert html_response(conn, 200) =~ "Find projects"
  end

  test "does not require authentication on GET /search", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, AdoptopossWeb.SearchLive))
    assert html_response(conn, 200)
    refute conn.halted
  end
end
