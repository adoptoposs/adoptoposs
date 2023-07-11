defmodule AdoptopossWeb.RepoController do
  use AdoptopossWeb, :controller

  def index(conn, _params) do
    username = conn.assigns.current_user.username
    redirect(conn, to: ~p"/settings/repos/#{username}")
  end
end
