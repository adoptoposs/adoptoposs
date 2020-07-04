defmodule AdoptopossWeb.LandingPageLiveTest do
  use AdoptopossWeb.LiveCase

  alias AdoptopossWeb.LandingPageLive
  alias Adoptoposs.{Tags, Network}
  alias Adoptoposs.Tags.Tag

  test "disconnected mount when logged out", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, LandingPageLive))

    html = html_response(conn, 200)
    assert html =~ "Find new (co-)maintainers"
    refute html =~ "Your Dashboard"
  end

  test "disconnected mount when logged out with query params", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, LandingPageLive, f: "something"))

    html = html_response(conn, 200)
    assert html =~ "Find new (co-)maintainers"
    refute html =~ "Your Dashboard"
  end

  @tag login_as: "user123"
  test "disconnected mount when logged in", %{conn: conn} do
    conn = get(conn, Routes.live_path(conn, LandingPageLive))

    html = html_response(conn, 200)
    assert html =~ "Your Dashboard"
    refute html =~ "Find new (co-)maintainers"
  end

  test "connected mount when logged out", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, LandingPageLive))
    assert html =~ "Find new (co-)maintainers"
  end

  @tag login_as: "user123"
  test "connected mount when logged in", %{conn: conn} do
    {:ok, _view, html} = live(conn, Routes.live_path(conn, LandingPageLive))
    assert html =~ "Your Dashboard"
  end

  @tag login_as: "user123"
  test "following suggested languages", %{conn: conn, user: user} do
    insert_tags(user.provider)
    {:ok, view, html} = live(conn, Routes.live_path(conn, LandingPageLive))

    assert html =~ "Follow All"
    assert Enum.count(Tags.list_user_tag_subscriptions(user)) == 0

    html = render_click(view, :follow_suggested_tags, %{})
    assert Enum.count(Tags.list_user_tag_subscriptions(user)) > 0
    assert {:error, {:live_redirect, %{kind: :push, to: "/"}}} = html
  end

  @tag login_as: "user123"
  test "filtering recommendations by language", %{conn: conn, user: user} do
    tag_subscriptions = insert_list(2, :tag_subscription, user: user)
    {:ok, view, html} = live(conn, Routes.live_path(conn, LandingPageLive))

    for tag_subscription <- tag_subscriptions do
      assert html =~ tag_subscription.tag.name

      params = %{"tag_subscription_id" => tag_subscription.id}
      html = render_click(view, :filter_recommendations, params)

      assert html =~ ~r/#{tag_subscription.tag.name}.+projects for you/is
    end
  end

  defp insert_tags(provider) do
    {:ok, {_page_info, repos}} = Network.user_repos("token", provider, 2)
    repos = repos |> Enum.uniq_by(& &1.language.name)

    for repo <- repos do
      insert(:tag, type: Tag.Language.type(), name: String.upcase(repo.language.name))
    end
  end
end
