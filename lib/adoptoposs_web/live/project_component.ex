defmodule AdoptopossWeb.ProjectComponent do
  use AdoptopossWeb, :live_component

  def render(assigns) do
    AdoptopossWeb.ProjectView.render("project.html", assigns)
  end
end
