defmodule AdoptopossWeb.SharingLiveTest do
  use AdoptopossWeb.LiveCase

  import Adoptoposs.Factory

  alias AdoptopossWeb.SharingLive

  test "disconnected mount of /projects/:uuid when logged out", %{conn: conn} do
    project = insert(:project)
    conn = get(conn, Routes.live_path(conn, SharingLive, project.uuid))
    assert html_response(conn, 200) =~ "#{project.repo_owner}/#{project.name}"
  end

  @tag login_as: "user123"
  test "disconnected mount of /projects/:uuid when logged in", %{conn: conn} do
    project = insert(:project)
    conn = get(conn, Routes.live_path(conn, SharingLive, project.uuid))
    assert html_response(conn, 200) =~ "#{project.repo_owner}/#{project.name}"
  end

  test "disconnected mount with invalid uuid", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, SharingLive, "invalid-uuid"))
    assert html_response(conn, 200) =~ "The project is not available"
  end

  test "connected mount of /projects/:uuid when logged out", %{conn: conn} do
    project = insert(:project)
    {:ok, _view, html} = live(conn, Routes.live_path(conn, SharingLive, project.uuid))
    assert html =~ "#{project.repo_owner}/#{project.name}"
  end

  @tag login_as: "user123"
  test "connected mount of /projects/:uuid when logged in", %{conn: conn} do
    project = insert(:project)
    {:ok, _view, html} = live(conn, Routes.live_path(conn, SharingLive, project.uuid))
    assert html =~ "#{project.repo_owner}/#{project.name}"
  end
end
