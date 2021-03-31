defmodule AdoptoppossWeb.Plugs.CurrentUserTest do
  use AdoptopossWeb.ConnCase

  import Adoptoposs.Factory

  alias AdoptopossWeb.Plugs.CurrentUser

  test "assigns nil as current_user to conn if not present in session" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> CurrentUser.call(%{})

    assert %{current_user: nil} = conn.assigns
  end

  test "assigns the current_user to conn if present in session" do
    user = insert(:user)

    conn =
      build_conn()
      |> init_test_session(%{user_id: user.id})
      |> CurrentUser.call(%{})

    assert %{current_user: ^user} = conn.assigns
  end
end
