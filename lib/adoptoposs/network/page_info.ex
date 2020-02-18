defmodule Adoptoposs.Network.PageInfo do
  @moduledoc """
  The schema representing a pagination page info.
  """

  use Ecto.Schema

  embedded_schema do
    field :has_next_page, :boolean
    field :end_cursor, :string
  end
end
