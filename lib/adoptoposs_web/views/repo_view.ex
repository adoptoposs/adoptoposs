defmodule AdoptopossWeb.RepoView do
  use AdoptopossWeb, :view

  def selected_attr(attr, other_attr) do
    if attr == other_attr, do: :selected
  end

  def hashed(text) do
    :crypto.hash(:md5, text) |> Base.encode16(case: :lower)
  end
end
