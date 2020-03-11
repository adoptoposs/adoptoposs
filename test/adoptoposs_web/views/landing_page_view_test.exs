defmodule AdoptopossWeb.LandingPageViewTest do
  use AdoptopossWeb.ConnCase, async: true

  import Adoptoposs.Factory

  alias AdoptopossWeb.LandingPageView

  test "tag_name/2 returns the name of the tag with given id" do
    tag_a = build(:tag, name: "A", id: 1)
    tag_b = build(:tag, name: "B", id: 2)

    tag_subscriptions = [
      build(:tag_subscription, tag: tag_b),
      build(:tag_subscription, tag: tag_a)
    ]

    assert LandingPageView.tag_name(tag_subscriptions, tag_a.id) == tag_a.name
  end
end
