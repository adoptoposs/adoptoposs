defmodule AdoptopossWeb.RepoControllerTest do
  use AdoptopossWeb.ConnCase

  test "GET /settings/repos requires authentication", %{conn: conn} do
    conn = get(conn, Routes.repo_path(conn, :index))
    path = Routes.live_path(conn, AdoptopossWeb.LandingPageLive)

    assert redirected_to(conn, 302) == path
    assert conn.halted
  end

  @tag login_as: "user123"
  test "GET /settings/repos redirects to repo live path", %{conn: conn, user: user} do
    conn = get(conn, Routes.repo_path(conn, :index))
    path = Routes.live_path(conn, AdoptopossWeb.RepoLive, user.username)

    assert redirected_to(conn, 302) == path
  end
end
