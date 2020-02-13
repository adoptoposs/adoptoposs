defmodule AdoptopossWeb.RepoControllerTest do
  use AdoptopossWeb.ConnCase

  test "requires authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.repo_path(conn, :index)),
        get(conn, Routes.repo_path(conn, :index, id: "orga_id"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
