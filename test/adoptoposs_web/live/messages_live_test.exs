defmodule AdoptopossWeb.MessagesLiveTest do
  use AdoptopossWeb.LiveCase

  import Adoptoposs.Factory

  test "disconnected mount requires authentication on all messages routes", %{conn: conn} do
    Enum.each(
      [
        ~p"/messages/contacted",
        ~p"/messages/interests"
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
        ~p"/messages/contacted",
        ~p"/messages/interests"
      ],
      fn path ->
        {:error, {:redirect, %{to: "/"}}} = live(conn, path)
      end
    )
  end

  @tag login_as: "user123"
  test "disconnected mount of /messages/contacted shows the page when logged in", %{conn: conn} do
    conn = get(conn, ~p"/messages/contacted")
    assert html_response(conn, 200) =~ "Contacted Maintainers"
  end

  @tag login_as: "user123"
  test "connected mount of /messages/contacted shows the page when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/messages/contacted")
    assert html =~ "Contacted Maintainers"
  end

  @tag login_as: "user123"
  test "disconnected mount of /messages/interests shows the page when logged in", %{conn: conn} do
    conn = get(conn, ~p"/messages/interests")
    assert html_response(conn, 200) =~ "Interests in your Projects"
  end

  @tag login_as: "user123"
  test "connected mount of /messages/interests shows the page when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/messages/interests")
    assert html =~ "Interests in your Projects"
  end

  @tag login_as: "user123"
  test "/messages/contacted shows the user's messages to others maintainers", %{
    conn: conn,
    user: user
  } do
    message = "Dear maintainer, how can I help? :)"
    insert(:interest, creator: user, message: message)
    {:ok, _view, html} = live(conn, ~p"/messages/contacted")
    assert html =~ message
  end

  @tag login_as: "user123"
  test "/messages/contacted shows an empty message if no interests where sent yet", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/messages/contacted")
    assert html =~ "You did not contact any maintainer yet."
  end

  @tag login_as: "user123"
  test "/messages/interests shows the messages from other users", %{
    conn: conn,
    user: user
  } do
    project = insert(:project, user: user)
    message = "Dear maintainer, how can I help? :)"
    insert(:interest, project: project, message: message)

    {:ok, _view, html} = live(conn, ~p"/messages/interests")
    assert html =~ project.name
    assert html =~ message
  end

  @tag login_as: "user123"
  test "/messages/interests shows an empty message if no interests where received yet", %{
    conn: conn
  } do
    {:ok, _view, html} = live(conn, ~p"/messages/interests")
    assert html =~ "You don’t have any messages here yet."
  end
end
