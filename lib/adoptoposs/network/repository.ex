defmodule Adoptoposs.Network.Repository do
  @moduledoc """
  The struct representing a project's repository.
  """

  alias Adoptoposs.Network.Repository.{User, Commit, Language}

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          star_count: integer(),
          watcher_count: integer(),
          issue_count: integer(),
          pull_request_count: integer(),
          owner: User.t(),
          last_commit: Commit.t(),
          language: Language.t()
        }

  defstruct name: nil,
            description: nil,
            url: nil,
            star_count: 0,
            watcher_count: 0,
            issue_count: 0,
            pull_request_count: 0,
            owner: %User{},
            last_commit: %Commit{},
            language: %Language{}
end
