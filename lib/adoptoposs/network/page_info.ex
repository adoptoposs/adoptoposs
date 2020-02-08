defmodule Adoptoposs.Network.PageInfo do
  @moduledoc """
  The struct representing a pagination page info.
  """

  @type t :: %__MODULE__{
          has_next_page: bool(),
          start_cursor: String.t()
        }

  defstruct has_next_page: false,
            start_cursor: nil
end
