defmodule Adoptoposs.Network.Repository.Commit do
  @moduledoc """
  The struct representing a commit of a repository.
  """

  alias Adoptoposs.Network.Repository.User

  @type t :: %__MODULE__{
          authored_at: DateTime.t(),
          author: User.t()
        }

  defstruct authored_at: nil,
            author: %User{}
end
