defmodule AdoptopossWeb.LiveCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a live view.

  Such tests rely on `AdoptopossWeb.ConnCase`,
  `Phoenix.LiveViewTest` and also import other
  functionality to make it easier to build common
  data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use AdoptopossWeb.ConnCase
      import Phoenix.LiveViewTest
    end
  end
end
