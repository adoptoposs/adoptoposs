defmodule AdoptopossWeb.ProjectLiveTest do
  use AdoptopossWeb.ConnCase
  import Phoenix.LiveViewTest
  import Adoptoposs.Factory

  alias AdoptopossWeb.ProjectLive

  test "requires authentication on all project routes", %{conn: conn} do
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

  test "GET /settings/projects shows the page for a logged in user", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> init_test_session(%{current_user: user})
      |> put_req_header("content-type", "html")
      |> get(Routes.live_path(conn, ProjectLive.Index))

    assert html_response(conn, 200) =~ "Your Submitted Projects"
    {:ok, _view, _html} = live(conn)
  end

  test "GET /projects/:id shows a project’s data and interests", %{conn: conn} do
    project = insert(:project)
    interests = insert_list(2, :interest, project: project)

    conn =
      conn
      |> init_test_session(%{current_user: project.user})
      |> put_req_header("content-type", "html")
      |> get(Routes.live_path(conn, ProjectLive.Show, project.id))

    assert html_response(conn, 200) =~ project.name

    for interest <- interests do
      assert html_response(conn, 200) =~ interest.message
    end

    {:ok, _view, _html} = live(conn)
  end

  test "GET /projects/:id is not accessible for anyone else but the creator", %{conn: conn} do
    project = insert(:project)
    insert_list(2, :interest, project: project)
    other_user = insert(:user)

    conn =
      conn
      |> init_test_session(%{current_user: other_user})
      |> put_req_header("content-type", "html")
      |> get(Routes.live_path(conn, ProjectLive.Show, project.id))

    assert html_response(conn, 302)
    assert {:error, %{redirect: %{to: Routes.live_path(conn, ProjectLive.Index)}}} == live(conn)
  end
end
