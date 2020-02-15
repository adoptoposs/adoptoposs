defmodule Adoptoposs.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :avatar_url, :string
    field :email, :string
    field :name, :string
    field :profile_url, :string
    field :provider, :string
    field :uid, :string
    field :username, :string

    has_many :projects, Adoptoposs.Dashboard.Project

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
