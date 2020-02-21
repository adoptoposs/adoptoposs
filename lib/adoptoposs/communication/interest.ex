defmodule Adoptoposs.Communication.Interest do
  use Ecto.Schema
  import Ecto.Changeset

  alias Adoptoposs.{Accounts, Dashboard}

  schema "interests" do
    belongs_to :creator, Accounts.User, foreign_key: :creator_id
    belongs_to :project, Dashboard.Project

    timestamps()
  end

  @doc false
  def changeset(interest, attrs) do
    interest
    |> cast(attrs, [:creator_id, :project_id])
    |> validate_required([:creator_id, :project_id])
    |> unique_constraint(:interest, name: :interests_creator_id_project_id_index)
  end
end
