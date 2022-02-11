defmodule AdoptopossWeb.ExploreLiveTest do
  use AdoptopossWeb.LiveCase
  use Bamboo.Test, shared: true

  alias AdoptopossWeb.ExploreLive
  alias Adoptoposs.{Communication.Interest, Tags.Tag}

  test "disconnected mount of /explore when logged out", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, ExploreLive))
    assert html_response(conn, 200) =~ "Explore Projects"
  end

  test "connected mount of /explore when logged out", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, ExploreLive))
    assert html =~ "Explore Projects"
  end

  @tag login_as: "user123"
  test "disconnected mount of /explore when logged in", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, ExploreLive))
    assert html_response(conn, 200) =~ "Explore Projects"
  end

  @tag login_as: "user123"
  test "connected mount of /explore when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, ExploreLive))
    assert html =~ "Explore Projects"
  end

  test "searching for a term displays the right results", %{conn: conn} do
    language = insert(:tag, name: "Elixir")
    project_1 = insert(:project, name: "Abcdefg", language: language)
    project_2 = insert(:project, name: "Hijklmn", language: language)

    path = Routes.live_path(conn, ExploreLive)

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
    refute html =~ project_2.name
    refute html =~ project_1.name
  end

  test "filtering by top ten languages", %{conn: conn} do
    language_1 = insert(:tag, type: Tag.Language.type(), name: "Elixir")
    language_2 = insert(:tag, type: Tag.Language.type(), name: "JavaScript")
    language_3 = insert(:tag, type: Tag.Language.type(), name: "Erlang")

    project_1 = insert(:project, name: "Abcdefg", language: language_1)
    project_2 = insert(:project, name: "Hijklmn", language: language_2)
    project_3 = insert(:project, name: "Opqrstu", language: language_3)

    path = Routes.live_path(conn, ExploreLive)
    {:ok, view, html} = live(conn, path)

    # all projects are shown by default
    assert html =~ project_1.name
    assert html =~ project_2.name
    assert html =~ project_3.name

    filter_section_id = "filters-sidebar-top-ten"
    language_toggle_1_id = "##{filter_section_id}-btn-toggle-#{language_1.id}"
    language_toggle_2_id = "##{filter_section_id}-btn-toggle-#{language_2.id}"

    assert view |> has_element?(language_toggle_1_id)
    assert view |> has_element?(language_toggle_2_id)

    # apply first language filter
    view
    |> element(language_toggle_1_id)
    |> render_click()

    assert_patched(view, Routes.live_path(conn, ExploreLive, q: nil, f: [language_1.id]))

    html = render(view)
    assert html =~ project_1.name
    refute html =~ project_2.name
    refute html =~ project_3.name

    # apply second language filter
    view
    |> element(language_toggle_2_id)
    |> render_click()

    html = render(view)

    filters = [language_2.id, language_1.id]
    assert_patched(view, Routes.live_path(conn, ExploreLive, q: nil, f: filters))

    assert html =~ project_1.name
    assert html =~ project_2.name
    refute html =~ project_3.name

    # remove first language filter
    view
    |> element("##{filter_section_id}-btn-toggle-#{language_1.id}")
    |> render_click()

    html = render(view)

    filters = [language_2.id]
    assert_patched(view, Routes.live_path(conn, ExploreLive, q: nil, f: filters))

    refute html =~ project_1.name
    assert html =~ project_2.name
    refute html =~ project_3.name

    # remove second language filter
    view
    |> element("##{filter_section_id}-btn-toggle-#{language_2.id}")
    |> render_click()

    html = render(view)
    assert_patched(view, Routes.live_path(conn, ExploreLive, q: nil, f: []))

    assert html =~ project_1.name
    assert html =~ project_2.name
    assert html =~ project_3.name
  end

  test "adding a filter by searching for a language", %{conn: conn} do
    # create some projects with tags to fill up the top ten filters
    projects =
      Enum.flat_map(1..10, fn _ ->
        language = insert(:tag, type: Tag.Language.type())
        insert_list(2, :project, language: language)
      end)

    language = insert(:tag, type: Tag.Language.type(), name: "Elixir")
    other_project = insert(:project, name: "Abcdefg", language: language)

    path = Routes.live_path(conn, ExploreLive)
    {:ok, view, _html} = live(conn, path)

    # load more to see all created projects
    html = render_hook(view, :load_more)

    # all projects are shown by default
    for project <- [other_project | projects] do
      assert html =~ project.name
    end

    filter_section_id = "filters-sidebar-searchable"

    # search for language
    view
    |> element("##{filter_section_id}-form")
    |> render_change(%{q: language.name})

    btn_add_id = "##{filter_section_id}-btn-add-#{language.id}"
    assert view |> has_element?(btn_add_id)

    # add filter
    view
    |> element(btn_add_id)
    |> render_click()

    html = render(view)
    assert_patched(view, Routes.live_path(conn, ExploreLive, q: nil, f: [language.id]))

    assert html =~ other_project.name

    for project <- projects do
      refute html =~ project.name
    end

    btn_remove_id = "##{filter_section_id}-btn-remove-#{language.id}"
    refute view |> has_element?(btn_add_id)
    assert view |> has_element?(btn_remove_id)

    # remove filter
    view
    |> element(btn_remove_id)
    |> render_click()

    render(view)
    assert_patched(view, Routes.live_path(conn, ExploreLive, q: nil, f: []))

    # load more to see all created projects
    html = render_hook(view, :load_more)

    assert view |> has_element?(btn_add_id)
    refute view |> has_element?(btn_remove_id)

    for project <- [other_project | projects] do
      assert html =~ project.name
    end
  end

  @tag login_as: "user123"
  test "filtering by favorite languages when logged in", %{conn: conn, user: user} do
    language_1 = insert(:tag, type: Tag.Language.type(), name: "Elixir")
    language_2 = insert(:tag, type: Tag.Language.type(), name: "JavaScript")

    project_1 = insert(:project, name: "Abcdefg", language: language_1)
    project_2 = insert(:project, name: "Hijklmn", language: language_2)

    insert(:tag_subscription, tag: language_1, user: user)

    path = Routes.live_path(conn, ExploreLive)
    {:ok, view, html} = live(conn, path)

    filter_section_id = "filters-sidebar-subscribed"
    btn_toggle_1_id = "##{filter_section_id}-btn-toggle-#{language_1.id}"
    btn_toggle_2_id = "##{filter_section_id}-btn-toggle-#{language_2.id}"

    assert view |> has_element?(btn_toggle_1_id)
    refute view |> has_element?(btn_toggle_2_id)

    assert html =~ project_1.name
    assert html =~ project_2.name

    # add filter
    view
    |> element(btn_toggle_1_id)
    |> render_click()

    html = render(view)
    assert_patched(view, Routes.live_path(conn, ExploreLive, q: nil, f: [language_1.id]))

    assert html =~ project_1.name
    refute html =~ project_2.name

    # remove filter
    view
    |> element(btn_toggle_1_id)
    |> render_click()

    html = render(view)
    assert_patched(view, Routes.live_path(conn, ExploreLive, q: nil, f: []))

    assert html =~ project_1.name
    assert html =~ project_2.name
  end

  test "contacting a project when logged out", %{conn: conn} do
    project = insert(:project)
    {:ok, view, _html} = live(conn, Routes.live_path(conn, ExploreLive))

    html = render_change(view, :search, %{q: project.name})
    assert html =~ project.name
    assert html =~ "Log in to contact"
  end

  @tag login_as: "user123"
  test "contacting a project when logged in", %{conn: conn, user: user} do
    project = insert(:project, user: build(:user, username: "other-user-than-logged-in"))

    {:ok, view, _html} = live(conn, Routes.live_path(conn, ExploreLive))

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

    {:ok, view, _html} = live(conn, Routes.live_path(conn, ExploreLive))

    html = render_change(view, :search, %{q: project.name})
    assert html =~ project.name
    refute html =~ "Contact maintainer"
  end
end
