defmodule AdoptopossWeb.RepoLive.RepoComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    AdoptopossWeb.RepoView.render("repo.html", assigns)
  end
end
