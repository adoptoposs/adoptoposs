defmodule AdoptopossWeb.RepoController do
  use AdoptopossWeb, :controller

  alias AdoptopossWeb.RepoLive

  def index(conn, _params) do
    username = conn.assigns.current_user.username
    redirect(conn, to: Routes.live_path(conn, RepoLive, username))
  end
end
