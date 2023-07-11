defmodule AdoptopossWeb.SharingControllerTest do
  use AdoptopossWeb.ConnCase

  describe "GET /p/:uuid" do
    @uuid "uuid"

    test "is redirected for logged out users", %{conn: conn} do
      conn = get(conn, ~p"/p/#{@uuid}")
      assert redirected_to(conn, 302) =~ ~p"/projects/#{@uuid}"
    end

    @tag login_as: "user123"
    test "is redirected for logged in users", %{conn: conn} do
      conn = get(conn, ~p"/p/#{@uuid}")
      assert redirected_to(conn, 302) =~ ~p"/projects/#{@uuid}"
    end
  end
end
