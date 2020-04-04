defmodule AdoptopossWeb.SharingController do
  use AdoptopossWeb, :controller

  alias AdoptopossWeb.SharingLive

  def index(conn, %{"uuid" => uuid}) do
    redirect(conn, to: Routes.live_path(conn, SharingLive, uuid))
  end
end
