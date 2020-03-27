defmodule AdoptopossWeb.PageController do
  use AdoptopossWeb, :controller

  def faq(conn, _params) do
    render(conn, "faq.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end
end
