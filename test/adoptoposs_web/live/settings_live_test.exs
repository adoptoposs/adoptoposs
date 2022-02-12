defmodule AdoptopossWeb.SettingsLiveTest do
  use AdoptopossWeb.LiveCase

  alias AdoptopossWeb.SettingsLive
  alias Adoptoposs.Accounts.Settings

  test "disconnected mount of /settings when logged out", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, SettingsLive))
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "connected mount of /settings when logged out", %{conn: conn} do
    {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.live_path(conn, SettingsLive))
  end

  @tag login_as: "user123"
  test "disconnected mount of /settings when logged in", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, SettingsLive))
    assert html_response(conn, 200) =~ "Settings"
  end

  @tag login_as: "user123"
  test "connected mount of /settings when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, SettingsLive))
    assert html =~ "Settings"
  end

  describe "tag subscriptions" do
    @tag login_as: "user123"
    test "adding a tag", %{conn: conn} do
      tag = insert(:tag, type: "language")
      {:ok, view, _html} = live(conn, Routes.live_path(conn, SettingsLive))

      html = render_change(view, :search_tags, %{q: tag.name})
      assert html =~ "Add #{tag.name}"
      refute html =~ "Remove #{tag.name}"

      html = render_click(view, :add_tag, %{tag_id: tag.id})
      assert html =~ "Remove #{tag.name}"
    end

    @tag login_as: "user123"
    test "adding a tag when already added", %{conn: conn, user: user} do
      tag = insert(:tag, type: "language")
      insert(:tag_subscription, user: user, tag: tag)

      {:ok, view, html} = live(conn, Routes.live_path(conn, SettingsLive))
      assert html =~ "Remove #{tag.name}"

      html = render_change(view, :search_tags, %{q: tag.name})
      refute html =~ "Add #{tag.name}"

      html = render_click(view, :add_tag, %{tag_id: tag.id})
      assert html =~ "Remove #{tag.name}"
    end

    @tag login_as: "user123"
    test "removing a tag", %{conn: conn, user: user} do
      tag_subscription = insert(:tag_subscription, user: user)

      {:ok, view, html} = live(conn, Routes.live_path(conn, SettingsLive))
      assert html =~ "Remove #{tag_subscription.tag.name}"

      html = render_click(view, :remove_tag, %{tag_subscription_id: tag_subscription.id})
      refute html =~ tag_subscription.tag.name
    end
  end

  describe "notifications" do
    @tag login_as: "user123"
    test "changing email_when_contacted", %{conn: conn} do
      {:ok, view, html} = live(conn, Routes.live_path(conn, SettingsLive))

      valid_values = Settings.email_when_contacted_values()
      assert radio_button_checked?(html, List.first(valid_values))

      for value <- valid_values do
        settings = %{email_when_contacted: value}
        html = render_change(view, :update_settings, %{user: %{settings: settings}})
        assert radio_button_checked?(html, value)

        settings = %{email_when_contacted: "not-valid"}
        html = render_change(view, :update_settings, %{user: %{settings: settings}})
        assert radio_button_checked?(html, value)
      end
    end

    @tag login_as: "user123"
    test "changing email_project_recommendations", %{conn: conn} do
      {:ok, view, html} = live(conn, Routes.live_path(conn, SettingsLive))

      valid_values = Settings.email_project_recommendations_values()
      assert radio_button_checked?(html, List.first(valid_values))

      for value <- valid_values do
        settings = %{email_project_recommendations: value}
        html = render_change(view, :update_settings, %{user: %{settings: settings}})
        assert radio_button_checked?(html, value)

        settings = %{email_project_recommendations: "not-valid"}
        html = render_change(view, :update_settings, %{user: %{settings: settings}})
        assert radio_button_checked?(html, value)
      end
    end

    defp radio_button_checked?(html, value) do
      html
      |> Floki.parse_document!()
      |> Floki.find("input[value=\"#{value}\"]")
      |> Floki.attribute("checked") == ["checked"]
    end
  end
end
