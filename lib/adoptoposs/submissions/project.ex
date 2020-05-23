defmodule Adoptoposs.Submissions.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias Adoptoposs.{Network, Accounts, Communication, Tags}

  schema "projects" do
    field :name, :string
    field :data, :map
    field :repo_id, :string
    field :repo_owner, :string
    field :description, :string
    field :uuid, :binary_id
    field :status, ProjectStatus

    belongs_to :language, Tags.Tag
    belongs_to :user, Accounts.User
    has_many :interests, Communication.Interest

    timestamps()
  end

  @cast_attrs [:name, :data, :user_id, :language_id, :repo_id, :repo_owner, :description]
  @required_attrs [:name, :data, :user_id, :language_id, :repo_owner, :repo_id, :description]

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
      repo_owner: (repository.owner || %{login: nil}).login,
      name: repository.name,
      language: (repository.language || %{name: nil}).name,
      data: repository |> Map.from_struct()
    })
  end
end
