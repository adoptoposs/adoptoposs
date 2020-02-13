defmodule AdoptopossWeb.PageControllerTest do
  use AdoptopossWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Adoptoposs!"
  end

  test "does not require authentication on GET /", %{conn: conn} do
    conn = get(conn, Routes.page_path(conn, :index))
    assert html_response(conn, 200)
    refute conn.halted
  end
end
