defmodule AdoptopossWeb.ProjectLiveTest do
  use AdoptopossWeb.ConnCase
  import Phoenix.LiveViewTest
  import Adoptoposs.Factory

  test "requires authentication on GET /settings/projects", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, AdoptopossWeb.ProjectLive))

    assert html_response(conn, 302)
    assert conn.halted
  end

  test "GET /settings/projects shows the page for a logged in user", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> init_test_session(%{current_user: user})
      |> put_req_header("content-type", "html")
      |> get(Routes.live_path(conn, AdoptopossWeb.ProjectLive))

    assert html_response(conn, 200) =~ "Your submitted projects"
    {:ok, _view, _html} = live(conn)

  end
end
