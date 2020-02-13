defmodule AdoptoppossWeb.Plugs.CurrentUserTest do
  use AdoptopossWeb.ConnCase

  import Plug.Test

  alias Adoptoposs.Accounts.User
  alias AdoptopossWeb.Plugs.CurrentUser

  test "assigns nil as current_user to conn if not present in session" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> CurrentUser.call(%{})

    assert %{current_user: nil} = conn.assigns
  end

  test "assigns the current_user to conn if present in session" do
    user = %User{}

    conn =
      build_conn()
      |> init_test_session(current_user: user)
      |> CurrentUser.call(%{})

    assert %{current_user: user} = conn.assigns
  end
end
