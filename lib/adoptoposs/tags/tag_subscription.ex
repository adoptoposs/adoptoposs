defmodule Adoptoposs.Tags.TagSubscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias Adoptoposs.{Accounts, Tags}

  schema "tag_subscriptions" do
    belongs_to :user, Accounts.User
    belongs_to :tag, Tags.Tag

    timestamps()
  end

  @doc false
  def changeset(tag_subscription, attrs) do
    tag_subscription
    |> cast(attrs, [:user_id, :tag_id])
    |> validate_required([:user_id, :tag_id])
    |> unique_constraint(:tag_subscriptions, name: :tag_subscriptions_user_id_tag_id_index)
  end
end
