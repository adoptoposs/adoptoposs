defmodule Adoptoposs.Network.Organization do
  @moduledoc """
  The schema representing a user’s organization.
  """

  use Ecto.Schema

  @primary_key {:id, :string, []}
  embedded_schema do
    field :name, :string
    field :description, :string
    field :avatar_url, :string
  end
end
