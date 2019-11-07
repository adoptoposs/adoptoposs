defmodule AdoptopossWeb.PageController do
  use AdoptopossWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
