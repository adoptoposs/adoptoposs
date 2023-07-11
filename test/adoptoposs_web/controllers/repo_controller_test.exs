defmodule AdoptopossWeb.RepoControllerTest do
  use AdoptopossWeb.ConnCase

  test "GET /settings/repos requires authentication", %{conn: conn} do
    conn = get(conn, ~p"/settings/repos")

    assert redirected_to(conn, 302) == ~p"/"
    assert conn.halted
  end

  @tag login_as: "user123"
  test "GET /settings/repos redirects to repo live path", %{conn: conn, user: user} do
    conn = get(conn, ~p"/settings/repos")
    path = ~p"/settings/repos/#{user.username}"

    assert redirected_to(conn, 302) == path
  end
end
