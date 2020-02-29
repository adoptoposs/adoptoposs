defmodule Adoptoposs.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Adoptoposs.{Dashboard, Communication, Tags}

  schema "users" do
    field :avatar_url, :string
    field :email, :string
    field :name, :string
    field :profile_url, :string
    field :provider, :string
    field :uid, :string
    field :username, :string

    has_many :projects, Dashboard.Project
    has_many :interests, Communication.Interest, foreign_key: :creator_id
    has_many :tag_subscriptions, Tags.TagSubscription, on_delete: :delete_all
    has_many :tags, through: [:tag_subscriptions, :tag]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:uid, :provider, :name, :username, :email, :avatar_url, :profile_url])
    |> validate_required([:uid, :provider, :name, :username, :email, :avatar_url, :profile_url])
    |> unique_constraint(:email)
    |> unique_constraint(:uid_provider)
  end
end
