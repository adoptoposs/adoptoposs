defmodule AdoptopossWeb.ProjectLiveTest do
  use AdoptopossWeb.LiveCase

  import Adoptoposs.Factory

  alias Adoptoposs.Submissions
  alias Adoptoposs.Submissions.Project

  test "disconnected mount requires authentication on project routes", %{conn: conn} do
    conn = get(conn, ~p"/settings/projects")
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "connected mount requires authentication on all project routes", %{conn: conn} do
    path = ~p"/settings/projects"
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, path)
  end

  @tag login_as: "user123"
  test "disconnected mount of /settings/projects shows the page when logged in", %{conn: conn} do
    conn = get(conn, ~p"/settings/projects")
    assert html_response(conn, 200) =~ "Your Submitted Projects"
  end

  @tag login_as: "user123"
  test "connected mount of /settings/projects shows the page when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/settings/projects")
    assert html =~ "Your Submitted Projects"
  end

  @tag login_as: "user123"
  test "editing a project", %{conn: conn, user: user} do
    project = insert(:project, user: user)

    {:ok, view, html} = live(conn, ~p"/settings/projects")
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

    {:ok, view, html} = live(conn, ~p"/settings/projects")
    assert html =~ project.name
    assert html =~ ~r/unpublish/i

    html = render_click(view, :unpublish, %{id: project.id})
    assert html =~ ~r/publish/i
    refute html =~ ~r/unpublish/i
  end

  @tag login_as: "user123"
  test "publishing a project", %{conn: conn, user: user} do
    project = insert(:project, user: user, status: :draft)

    {:ok, view, html} = live(conn, ~p"/settings/projects")
    assert html =~ project.name
    assert html =~ ~r/publish/i
    refute html =~ ~r/unpublish/i

    html = render_click(view, :publish, %{id: project.id})
    assert html =~ ~r/unpublish/i
  end

  @tag login_as: "user123"
  test "removing a project", %{conn: conn, user: user} do
    project = insert(:project, user: user)

    {:ok, view, html} = live(conn, ~p"/settings/projects")
    assert html =~ project.description
    html = render_submit(view, :remove, %{id: project.id})
    refute html =~ project.description
    assert Adoptoposs.Repo.aggregate(Project, :count) == 0
  end

  @tag login_as: "user123"
  test "removing another user’s project is not possible", %{conn: conn} do
    project = insert(:project)

    {:ok, view, _html} = live(conn, ~p"/settings/projects")
    render_submit(view, :remove, %{id: project.id})
    assert Submissions.get_project!(project.id).id == project.id
  end
end
