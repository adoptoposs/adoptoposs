defmodule AdoptopossWeb.SharingControllerTest do
  use AdoptopossWeb.ConnCase

  alias AdoptopossWeb.SharingLive

  describe "GET /p/:uuid" do
    @uuid "uuid"

    test "is redirected for logged out users", %{conn: conn} do
      conn = get(conn, Routes.sharing_path(conn, :index, @uuid))
      assert redirected_to(conn, 302) =~ Routes.live_path(conn, SharingLive, @uuid)
    end

    @tag login_as: "user123"
    test "is redirected for logged in users", %{conn: conn} do
      conn = get(conn, Routes.sharing_path(conn, :index, @uuid))
      assert redirected_to(conn, 302) =~ Routes.live_path(conn, SharingLive, @uuid)
    end
  end
end
