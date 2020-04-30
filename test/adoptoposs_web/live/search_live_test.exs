defmodule AdoptopossWeb.SearchLiveTest do
  use AdoptopossWeb.LiveCase
  use Bamboo.Test, shared: true

  alias AdoptopossWeb.SearchLive
  alias Adoptoposs.Communication.Interest

  test "disconnected mount of /search when logged out", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, SearchLive))
    assert html_response(conn, 200) =~ "Find projects"
  end

  test "connected mount of /search when logged out", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, SearchLive))
    assert html =~ "Find projects"
  end

  @tag login_as: "user123"
  test "disconnected mount of /search when logged in", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, SearchLive))
    assert html_response(conn, 200) =~ "Find projects"
  end

  @tag login_as: "user123"
  test "connected mount of /search when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, SearchLive))
    assert html =~ "Find projects"
  end

  test "searching for a term displays the right results", %{conn: conn} do
    language = insert(:tag, name: "Elixir")
    project_1 = insert(:project, name: "Abcdefg", language: language)
    project_2 = insert(:project, name: "Hijklmn", language: language)

    path = Routes.live_path(conn, SearchLive)

    {:ok, view, _html} = live(conn, path)
    html = render_change(view, :search, %{q: project_1.name})
    assert html =~ project_1.name
    refute html =~ project_2.name

    {:ok, view, _html} = live(conn, path)
    html = render_change(view, :search, %{q: project_2.name})
    assert html =~ project_2.name
    refute html =~ project_1.name

    {:ok, view, _html} = live(conn, path)
    html = render_change(view, :search, %{q: language.name})
    assert html =~ project_2.name
    assert html =~ project_1.name
  end

  test "contacting a project when logged out", %{conn: conn} do
    project = insert(:project)
    {:ok, view, _html} = live(conn, Routes.live_path(conn, SearchLive))

    html = render_change(view, :search, %{q: project.name})
    assert html =~ project.name
    assert html =~ "Log in to contact"
  end

  @tag login_as: "user123"
  test "contacting a project when logged in", %{conn: conn, user: user} do
    project = insert(:project, user: build(:user, username: "other-user-than-logged-in"))

    {:ok, view, _html} = live(conn, Routes.live_path(conn, SearchLive))

    html = render_change(view, :search, %{q: project.name})
    assert html =~ project.name
    assert html =~ ~r/contact maintainer/i

    html =
      view
      |> element("#btn-interest-#{project.id}")
      |> render_click(%{id: project.id})

    assert html =~ ~r/send/i

    html =
      view
      |> element("#form-interest-#{project.id}")
      |> render_submit(%{interest: %{message: "Hi"}})

    assert html =~ ~r/you contacted the maintainer/i

    assert %Interest{} =
             Adoptoposs.Repo.get_by(Interest, project_id: project.id, creator_id: user.id)

    assert_email_delivered_with(
      subject: "[Adoptoposs][#{project.name}] #{user.name} wrote you a message",
      to: [project.user.email]
    )
  end

  @tag login_as: "user123"
  test "contacting your own project when logged in is not possible", %{conn: conn, user: user} do
    project = insert(:project, user: user)

    {:ok, view, _html} = live(conn, Routes.live_path(conn, SearchLive))

    html = render_change(view, :search, %{q: project.name})
    assert html =~ project.name
    refute html =~ "Contact maintainer"
  end
end
