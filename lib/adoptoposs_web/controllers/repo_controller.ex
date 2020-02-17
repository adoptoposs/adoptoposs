defmodule AdoptopossWeb.RepoController do
  use AdoptopossWeb, :controller

  alias Adoptoposs.Accounts.User
  alias AdoptopossWeb.RepoLive

  def index(conn, _params) do
    %User{username: id} = get_session(conn, :current_user)
    redirect(conn, to: Routes.live_path(conn, RepoLive, id))
  end
end
