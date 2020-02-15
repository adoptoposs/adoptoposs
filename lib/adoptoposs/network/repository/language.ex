defmodule Adoptoposs.Network.Repository.Language do
  @moduledoc """
  The schema representing a repository’s programming language.
  """

  use Ecto.Schema

  @json_fields [:name, :color]
  @default_name "¯\\_(ツ)_/¯"
  @default_color "#666666"

  @derive {Jason.Encoder, only: @json_fields}
  embedded_schema do
    field :name, :string, default: @default_name
    field :color, :string, default: @default_color
  end
end
