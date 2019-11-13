defmodule Adoptoposs.Network.Repository.User do
  @type t :: %__MODULE__{
          login: String.t(),
          name: String.t(),
          avatar_url: String.t(),
          profile_url: String.t(),
          email: String.t() | none()
        }

  defstruct login: nil,
            name: nil,
            avatar_url: nil,
            profile_url: nil,
            email: nil
end
