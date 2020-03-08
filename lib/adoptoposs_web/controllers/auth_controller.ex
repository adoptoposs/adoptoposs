defmodule AdoptopossWeb.AuthController do
  use AdoptopossWeb, :controller
  alias Adoptoposs.Accounts

  plug Ueberauth

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.upsert_user(auth) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_session(:token, auth.credentials.token)
        |> configure_session(renew: true)
        |> redirect(to: NavigationHistory.last_path(conn, default: "/"))

      {:error, _} ->
        conn
        |> assign(:ueberauth_failure, nil)
        |> callback(%{})
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _failure}} = conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed.")
    |> redirect(to: "/")
  end
end
