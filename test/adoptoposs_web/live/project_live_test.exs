defmodule AdoptopossWeb.ProjectLiveTest do
  use AdoptopossWeb.LiveCase

  import Adoptoposs.Factory

  alias AdoptopossWeb.ProjectLive

  test "disconnected mount requires authentication on all project routes", %{conn: conn} do
    Enum.each(
      [
        Routes.live_path(conn, ProjectLive.Index),
        Routes.live_path(conn, ProjectLive.Show, 1)
      ],
      fn path ->
        conn = get(conn, path)
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  test "connected mount requires authentication on all project routes", %{conn: conn} do
    Enum.each(
      [
        Routes.live_path(conn, ProjectLive.Index),
        Routes.live_path(conn, ProjectLive.Show, 1)
      ],
      fn path ->
        {:error, %{redirect: %{to: "/"}}} = live(conn, path)
      end
    )
  end

  @tag login_as: "user123"
  test "disconnected mount of /settings/projects shows the page when logged in", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, ProjectLive.Index))
    assert html_response(conn, 200) =~ "Your Submitted Projects"
  end

  @tag login_as: "user123"
  test "connected mount of /settings/projects shows the page when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, ProjectLive.Index))
    assert html =~ "Your Submitted Projects"
  end

  @tag login_as: "user123"
  test "disconnected mount of /projects/:id shows a project’s data and interests", %{
    conn: conn,
    user: user
  } do
    project = insert(:project, user: user)
    interests = insert_list(2, :interest, project: project)

    conn = get(conn, Routes.live_path(conn, ProjectLive.Show, project.id))
    html = html_response(conn, 200)

    assert html =~ project.name

    for interest <- interests do
      assert html =~ interest.message
    end
  end

  @tag login_as: "user123"
  test "connected mount of /projects/:id shows a project’s data and interests", %{
    conn: conn,
    user: user
  } do
    project = insert(:project, user: user)
    interests = insert_list(2, :interest, project: project)

    {:ok, _view, html} = live(conn, Routes.live_path(conn, ProjectLive.Show, project.id))

    for interest <- interests do
      assert html =~ interest.message
    end
  end

  @tag login_as: "user123"
  test "disconnected mount of /projects/:id is not accessible for anyone else but the creator", %{
    conn: conn
  } do
    project = insert(:project)
    insert_list(2, :interest, project: project)

    conn = get(conn, Routes.live_path(conn, ProjectLive.Show, project.id))
    assert html_response(conn, 302)
  end

  @tag login_as: "user123"
  test "connected mount of /projects/:id is not accessible for anyone else but the creator", %{
    conn: conn
  } do
    project = insert(:project)
    insert_list(2, :interest, project: project)

    assert {:error, %{redirect: %{to: Routes.live_path(conn, ProjectLive.Index)}}} ==
             live(conn, Routes.live_path(conn, ProjectLive.Show, project.id))
  end
end
