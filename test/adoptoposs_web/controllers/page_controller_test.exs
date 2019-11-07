defmodule AdoptopossWeb.PageControllerTest do
  use AdoptopossWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Adoptoposs!"
  end
end
