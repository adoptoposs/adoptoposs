defmodule AdoptopossWeb.RepoController do
  use AdoptopossWeb, :controller

  alias Adoptoposs.Accounts.User
  alias AdoptopossWeb.RepoLive

  def index(conn, %{}) do
    %User{username: id} = get_session(conn, :current_user)
    redirect(conn, to: Routes.live_path(conn, RepoLive.Index, id))
  end
end
