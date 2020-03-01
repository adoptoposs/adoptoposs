defmodule Adoptoposs.Tags.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Adoptoposs.{Dashboard, Tags}

  schema "tags" do
    field :color, :string
    field :name, :string
    field :type, :string

    has_many :tag_subscriptions, Tags.TagSubscription, on_delete: :delete_all
    has_many :users, through: [:tag_subscriptions, :user]
    has_many :projects, Dashboard.Project, foreign_key: :language_id

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :type, :color])
    |> validate_required([:name, :type, :color])
  end

  defmodule Utility do
    alias Adoptoposs.Tags.Tag

    @tag_type "utility"
    @unknown_tag_name "unknown"
    @unknown_tag_color "#a0aec0"

    @doc """
    Returns the type value for utility tags.
    """
    def type, do: @tag_type

    @doc """
    Returns an "unknown" utility tag.
    """
    def unknown do
      %Tag{
        name: @unknown_tag_name,
        color: @unknown_tag_color,
        type: @tag_type
      }
    end
  end

  defmodule Language do
    alias Adoptoposs.Tags.Tag

    @tag_type "language"

    @doc """
    Returns the type value for language tags.
    """
    def type, do: @tag_type

    @doc """
    Returns a language tag with the given `attrs`.
    """
    def new(attrs \\ []) do
      struct(Tag, put_in(attrs, [:type], @tag_type))
    end
  end
end
