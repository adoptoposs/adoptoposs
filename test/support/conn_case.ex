defmodule AdoptopossWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AdoptopossWeb.ConnCase
      import Adoptoposs.Factory

      use AdoptopossWeb, :verified_routes

      alias AdoptopossWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint AdoptopossWeb.Endpoint

      setup %{conn: conn} = config do
        conn = put_req_header(conn, "content-type", "html")

        conn =
          if username = config[:login_as] do
            user = insert(:user, username: username, provider: "github")

            conn
            |> assign(:current_user, user)
            |> init_test_session(%{user_id: user.id, token: Ecto.UUID.generate()})
          else
            assign(conn, :current_user, nil)
          end

        {:ok, %{conn: conn, user: conn.assigns.current_user}}
      end
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Adoptoposs.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
