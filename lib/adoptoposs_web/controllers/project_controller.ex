defmodule AdoptopossWeb.ProjectController do
  use AdoptopossWeb, :controller

  alias Adoptoposs.Accounts.User

  def index(conn, %{}) do
    %User{username: username} = get_session(conn, :current_user)
    redirect(conn, to: Routes.live_path(conn, AdoptopossWeb.Project.IndexLive, username))
  end
end
