defmodule Adoptoposs.Network.Repository do
  @moduledoc """
  The schema representing a remote repository.
  """

  use Ecto.Schema

  alias Adoptoposs.Network.Repository

  @derive {Jason.Encoder, []}
  @primary_key {:id, :string, []}
  embedded_schema do
    field :name, :string
    field :description, :string
    field :url, :string
    field :star_count, :integer, default: 0
    field :watcher_count, :integer, default: 0
    field :issue_count, :integer, default: 0
    field :pull_request_count, :integer, default: 0

    embeds_one :owner, Repository.User
    embeds_one :language, Repository.Language
  end
end
