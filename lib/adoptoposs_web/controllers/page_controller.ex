defmodule AdoptopossWeb.PageController do
  use AdoptopossWeb, :controller

  alias Adoptoposs.Dashboard

  def index(conn, _params) do
    projects = Dashboard.list_projects(limit: 20)
    render(conn, "index.html", projects: projects)
  end
end
