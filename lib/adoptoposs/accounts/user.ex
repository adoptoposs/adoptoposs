defmodule Adoptoposs.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Adoptoposs.{Accounts, Dashboard, Communication, Tags}

  schema "users" do
    field :avatar_url, :string
    field :email, :string
    field :name, :string
    field :profile_url, :string
    field :provider, :string
    field :uid, :string
    field :username, :string

    embeds_one :settings, Accounts.Settings, on_replace: :update
    has_many :projects, Dashboard.Project
    has_many :interests, Communication.Interest, foreign_key: :creator_id
    has_many :tag_subscriptions, Tags.TagSubscription, on_delete: :delete_all
    has_many :tags, through: [:tag_subscriptions, :tag]

    timestamps()
  end

  @required_attrs [:uid, :provider, :name, :username, :email, :avatar_url, :profile_url]

  @doc false
  def create_changeset(user, attrs) do
    user
    |> update_changeset(attrs)
    |> put_embed(:settings, %{})
  end

  @doc false
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint(:email)
    |> unique_constraint(:uid_provider)
  end

  @doc false
  def settings_changeset(user, attrs) do
    user
    |> change()
    |> put_embed(:settings, Accounts.Settings.changeset(user.settings, attrs))
  end
end
