defmodule Adoptoposs.Tags.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :color, :string
    field :name, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :type, :color])
    |> validate_required([:name, :type, :color])
  end
end
