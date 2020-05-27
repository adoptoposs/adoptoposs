defmodule AdoptopossWeb.ProjectLiveTest do
  use AdoptopossWeb.LiveCase

  import Adoptoposs.Factory

  alias AdoptopossWeb.ProjectLive
  alias Adoptoposs.Submissions
  alias Adoptoposs.Submissions.Project

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
        {:error, {:redirect, %{to: "/"}}} = live(conn, path)
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

    conn = get(conn, Routes.live_path(conn, ProjectLive.Show, project.id))
    assert html_response(conn, 302)
  end

  @tag login_as: "user123"
  test "connected mount of /projects/:id is not accessible for anyone else but the creator", %{
    conn: conn
  } do
    project = insert(:project)

    assert {:error, {:live_redirect, %{to: path}}} =
             live(conn, Routes.live_path(conn, ProjectLive.Show, project.id))

    assert path == Routes.live_path(conn, ProjectLive.Index)
  end

  @tag login_as: "user123"
  test "editing a project", %{conn: conn, user: user} do
    project = insert(:project, user: user)

    {:ok, view, html} = live(conn, Routes.live_path(conn, ProjectLive.Index))
    assert html =~ project.name
    assert html =~ ~r/edit/i
    refute html =~ ~r/save/i
    refute html =~ ~r/cancel/i

    html = render_click(view, :edit, %{id: project.id})
    assert html =~ ~r/save/i
    assert html =~ ~r/cancel/i

    html = render_click(view, :cancel_edit, %{})
    assert html =~ ~r/edit/i
    refute html =~ ~r/save/i
    refute html =~ ~r/cancel/i

    render_click(view, :edit, %{id: project.id})

    description = "Updated " <> project.description
    params = %{"project" => %{"description" => description}}
    html = render_submit(view, :update, params)
    assert html =~ description
  end

  @tag login_as: "user123"
  test "unpublishing a project", %{conn: conn, user: user} do
    project = insert(:project, user: user, status: :published)

    {:ok, view, html} = live(conn, Routes.live_path(conn, ProjectLive.Index))
    assert html =~ project.name
    assert html =~ ~r/unpublish/i

    html = render_click(view, :unpublish, %{id: project.id})
    assert html =~ ~r/publish/i
    refute html =~ ~r/unpublish/i
  end

  @tag login_as: "user123"
  test "publishing a project", %{conn: conn, user: user} do
    project = insert(:project, user: user, status: :draft)

    {:ok, view, html} = live(conn, Routes.live_path(conn, ProjectLive.Index))
    assert html =~ project.name
    assert html =~ ~r/publish/i
    refute html =~ ~r/unpublish/i

    html = render_click(view, :publish, %{id: project.id})
    assert html =~ ~r/unpublish/i
  end

  @tag login_as: "user123"
  test "removing a project", %{conn: conn, user: user} do
    project = insert(:project, user: user)

    {:ok, view, html} = live(conn, Routes.live_path(conn, ProjectLive.Index))
    assert html =~ project.description
    html = render_submit(view, :remove, %{id: project.id})
    refute html =~ project.description
    assert Adoptoposs.Repo.aggregate(Project, :count) == 0
  end

  @tag login_as: "user123"
  test "removing another user’s project is not possible", %{conn: conn} do
    project = insert(:project)

    {:ok, view, _html} = live(conn, Routes.live_path(conn, ProjectLive.Index))
    render_submit(view, :remove, %{id: project.id})
    assert Submissions.get_project!(project.id).id == project.id
  end
end
