defmodule AdoptopossWeb.PageControllerTest do
  use AdoptopossWeb.ConnCase

  test "GET /faq", %{conn: conn} do
    conn = get(conn, ~p"/faq")
    assert html_response(conn, 200) =~ "Frequently Asked Questions"
  end

  test "GET /privacy", %{conn: conn} do
    conn = get(conn, ~p"/privacy")
    assert html_response(conn, 200) =~ "Privacy Policy"
  end

  @tag login_as: "user123"
  test "page paths are visible for logged in users", %{conn: conn} do
    [~p"/faq", ~p"/privacy"]
    |> Enum.each(fn path ->
      conn = get(conn, path)
      assert html_response(conn, 200)
    end)
  end
end
