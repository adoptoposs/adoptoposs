defmodule AdoptopossWeb.SharingController do
  use AdoptopossWeb, :controller

  def index(conn, %{"uuid" => uuid}) do
    redirect(conn, to: ~p"/projects/#{uuid}")
  end
end
