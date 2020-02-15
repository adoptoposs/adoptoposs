defmodule Adoptoposs.Network.Repository.User do
  @moduledoc """
  The schema representing a contributing user of a repository.
  """

  use Ecto.Schema

  @json_fields [:login, :name, :avatar_url, :profile_url, :email]

  @derive {Jason.Encoder, only: @json_fields}
  embedded_schema do
    field :login, :string
    field :name, :string
    field :avatar_url, :string
    field :profile_url, :string
    field :email, :string
  end
end
