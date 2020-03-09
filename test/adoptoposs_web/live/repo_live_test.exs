defmodule AdoptopossWeb.RepoLiveTest do
  use AdoptopossWeb.LiveCase

  test "disconnected mount of /settings/repos/:orga_id when logged out", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, AdoptopossWeb.RepoLive, "orga"))
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "connected mount of /settings/repos/:orga_id when logged out", %{conn: conn} do
    assert {:error, %{redirect: %{to: "/"}}} =
             live(conn, Routes.live_path(conn, AdoptopossWeb.RepoLive, "orga"))
  end

  @tag login_as: "user123"
  test "disconnected mount of /settings/repos/:orga_id when logged in", %{conn: conn, user: user} do
    conn = get(conn, Routes.live_path(conn, AdoptopossWeb.RepoLive, user.username))
    assert html_response(conn, 200) =~ "Submit Repo from"
  end

  @tag login_as: "user123"
  test "connected mount of /settings/repos/:orga_id when logged in", %{conn: conn, user: user} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, AdoptopossWeb.RepoLive, user.username))
    assert html =~ "Submit Repo from"
  end
end
