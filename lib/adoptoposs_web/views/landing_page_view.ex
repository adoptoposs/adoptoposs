defmodule AdoptopossWeb.LandingPageView do
  use AdoptopossWeb, :view

  @doc """
  Returns the name of the tag in `tag_subscription` with the given `tag_id`.
  """
  def tag_name(tag_subscriptions, tag_id) do
    Enum.find(tag_subscriptions, &(&1.tag.id == tag_id)).tag.name
  end
end
