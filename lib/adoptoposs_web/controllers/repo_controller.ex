defmodule AdoptopossWeb.RepoController do
  use AdoptopossWeb, :controller

  alias Adoptoposs.Accounts.User
  alias AdoptopossWeb.Repo

  def index(conn, %{}) do
    %User{username: username} = get_session(conn, :current_user)
    redirect(conn, to: Routes.live_path(conn, Repo.IndexLive, username))
  end
end
