defmodule Adoptoposs.Network.Repository.Commit do
  @moduledoc """
  The schema representing a commit of a repository.
  """

  use Ecto.Schema
  alias Adoptoposs.Network.Repository

  @json_fields [:authored_at, :author]

  @derive {Jason.Encoder, only: @json_fields}
  embedded_schema do
    field :authored_at, :naive_datetime
    embeds_one :author, Repository.User
  end
end
