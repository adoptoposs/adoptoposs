defmodule AdoptopossWeb.SettingsLiveTest do
  use AdoptopossWeb.LiveCase

  alias AdoptopossWeb.SettingsLive

  test "disconnected mount of /settings when logged out", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, SettingsLive))
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "connected mount of /settings when logged out", %{conn: conn} do
    {:error, %{redirect: %{to: "/"}}} = live(conn, Routes.live_path(conn, SettingsLive))
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
    test "following a tag", %{conn: conn} do
      tag = insert(:tag, type: "language")
      {:ok, view, _html} = live(conn, Routes.live_path(conn, SettingsLive))

      html = render_change(view, :search_tags, %{q: tag.name})
      assert html =~ "Follow #{tag.name}"
      refute html =~ "Unfollow #{tag.name}"

      html = render_click(view, :follow_tag, %{tag_id: tag.id})
      assert html =~ "Unfollow #{tag.name}"
    end

    @tag login_as: "user123"
    test "following a tag when already following", %{conn: conn, user: user} do
      tag = insert(:tag, type: "language")
      insert(:tag_subscription, user: user, tag: tag)

      {:ok, view, html} = live(conn, Routes.live_path(conn, SettingsLive))
      assert html =~ "Unfollow #{tag.name}"

      html = render_change(view, :search_tags, %{q: tag.name})
      refute html =~ "Follow #{tag.name}"

      html = render_click(view, :follow_tag, %{tag_id: tag.id})
      assert html =~ "Unfollow #{tag.name}"
    end

    @tag login_as: "user123"
    test "unfollowing a tag", %{conn: conn, user: user} do
      tag_subscription = insert(:tag_subscription, user: user)

      {:ok, view, html} = live(conn, Routes.live_path(conn, SettingsLive))
      assert html =~ "Unfollow #{tag_subscription.tag.name}"

      html = render_click(view, :unfollow_tag, %{tag_subscription_id: tag_subscription.id})
      refute html =~ tag_subscription.tag.name
    end
  end

  describe "notifications" do
    @tag login_as: "user123"
    test "changing email_when_contacted", %{conn: conn} do
      {:ok, view, html} = live(conn, Routes.live_path(conn, SettingsLive))
      assert html =~ "value=\"immediately\" checked"

      html =
        render_change(view, :update_settings, %{user: %{settings: %{email_when_contacted: "off"}}})

      assert html =~ "value=\"off\" checked"

      html =
        render_change(view, :update_settings, %{
          user: %{settings: %{email_when_contacted: "not-valid"}}
        })

      assert html =~ "value=\"off\" checked"

      html =
        render_change(view, :update_settings, %{
          user: %{settings: %{email_when_contacted: "immediately"}}
        })

      assert html =~ "value=\"immediately\" checked"
    end
  end
end
