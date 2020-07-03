defmodule AdoptopossWeb.LiveView do
  @moduledoc """
  Basic module for Adoptoposs live views.
  """

  defmacro __using__(_opts) do
    quote do
      use Phoenix.LiveView, layout: {AdoptopossWeb.LayoutView, "live.html"}
      use AdoptopossWeb.LiveHelpers
    end
  end
end
