defmodule AdoptopossWeb.RepoLiveTest do
  use AdoptopossWeb.ConnCase

  test "requires authentication on GET /settings/repos/:orga_id", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, AdoptopossWeb.RepoLive, "orga"))

    assert html_response(conn, 302)
    assert conn.halted
  end
end
