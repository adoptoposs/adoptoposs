defmodule Adoptoposs.Network.Repository.Language do
  @moduledoc """
  The struct representing a repository’s programming language.
  """

  @default_name "¯\\_(ツ)_/¯"
  @default_color "#666666"

  @type t :: %__MODULE__{
          name: String.t(),
          color: String.t()
        }

  defstruct name: @default_name,
            color: @default_color
end
