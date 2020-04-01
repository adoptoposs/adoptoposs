defmodule AdoptopossWeb.PageControllerTest do
  use AdoptopossWeb.ConnCase

  test "GET /faq", %{conn: conn} do
    conn = get(conn, Routes.page_path(conn, :faq))
    assert html_response(conn, 200) =~ "Frequently Asked Questions"
  end

  test "GET /privacy", %{conn: conn} do
    conn = get(conn, Routes.page_path(conn, :privacy))
    assert html_response(conn, 200) =~ "Privacy Policy"
  end

  @tag login_as: "user123"
  test "page paths are visible for logged in users", %{conn: conn} do
    [:faq, :privacy]
    |> Enum.each(fn action ->
      conn = get(conn, Routes.page_path(conn, action))
      assert html_response(conn, 200)
    end)
  end
end
