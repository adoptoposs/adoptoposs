defmodule Adoptoposs.Tags.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Adoptoposs.Tags

  schema "tags" do
    field :color, :string
    field :name, :string
    field :type, :string

    has_many :tag_subscriptions, Tags.TagSubscription, on_delete: :delete_all
    has_many :users, through: [:tag_subscriptions, :user]

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :type, :color])
    |> validate_required([:name, :type, :color])
  end
end
