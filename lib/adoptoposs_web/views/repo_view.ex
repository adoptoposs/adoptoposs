defmodule AdoptopossWeb.RepoView do
  use AdoptopossWeb, :view

  def selected_attr(attr, other_attr) do
    if attr == other_attr, do: :selected
  end
end
