defmodule Adoptoposs.Dashboard.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias Adoptoposs.{Network, Accounts, Communication}

  schema "projects" do
    field :name, :string
    field :language, :string
    field :data, :map
    field :repo_id, :string
    field :description, :string

    belongs_to :user, Accounts.User
    has_many :interests, Communication.Interest

    timestamps()
  end

  @cast_attrs [:name, :language, :data, :repo_id, :user_id, :description]
  @required_attrs [:name, :language, :data, :user_id, :repo_id]

  @doc false
  def create_changeset(project, %Network.Repository{} = repository, attrs \\ %{}) do
    changeset(project, attrs |> merge_attrs(repository))
  end

  defp changeset(project, attrs) do
    project
    |> cast(attrs, @cast_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint(:project, name: :projects_user_id_repo_id_index)
  end

  @doc false
  def update_changeset(project, attrs \\ %{}) do
    project
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end

  defp merge_attrs(attrs, repository) do
    Map.merge(attrs, %{
      repo_id: repository.id,
      name: repository.name,
      language: (repository.language || %{name: nil}).name,
      data: repository |> Map.from_struct()
    })
  end
end
