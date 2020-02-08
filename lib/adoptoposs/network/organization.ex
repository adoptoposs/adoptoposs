defmodule Adoptoposs.Network.Organization do
  @moduledoc """
  The struct representing a user’s organization.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          description: String.t(),
          avatar_url: String.t()
        }

  defstruct id: nil,
            name: nil,
            description: nil,
            avatar_url: nil
end
