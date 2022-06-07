defmodule Adoptoposs.Submissions.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias Adoptoposs.{Network, Accounts, Communication, Tags}

  @statuses ~w(published draft)a

  schema "projects" do
    field :name, :string
    field :data, :map
    field :repo_id, :string
    field :repo_owner, :string
    field :repo_description, :string
    field :description, :string
    field :uuid, :binary_id
    field :status, Ecto.Enum, values: @statuses

    belongs_to :language, Tags.Tag
    belongs_to :user, Accounts.User
    has_many :interests, Communication.Interest

    timestamps()
  end

  @cast_attrs [
    :name,
    :data,
    :user_id,
    :language_id,
    :repo_id,
    :repo_owner,
    :repo_description,
    :description
  ]
  @required_attrs [
    :name,
    :data,
    :user_id,
    :language_id,
    :repo_owner,
    :repo_id,
    :repo_description,
    :description
  ]
  @repo_attrs [:name, :data, :language_id, :repo_owner, :repo_id, :repo_description]

  @doc false
  def create_changeset(project, %Network.Repository{} = repository, attrs \\ %{}) do
    changeset(project, attrs |> merge_attrs(repository))
  end

  @doc false
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

  @doc false
  def status_changeset(project, attrs \\ %{}) do
    project
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  @doc false
  def update_data_changeset(project, %Network.Repository{} = repository, attrs \\ %{}) do
    project
    |> cast(attrs |> merge_attrs(repository), @repo_attrs)
    |> validate_required(@repo_attrs)
    |> unique_constraint(:project, name: :projects_user_id_repo_id_index)
  end

  defp merge_attrs(attrs, repository) do
    Map.merge(attrs, repo_attrs(repository))
  end

  defp repo_attrs(repository) do
    %{
      repo_id: repository.id,
      repo_owner: (repository.owner || %{login: nil}).login,
      repo_description: repository.description,
      name: repository.name,
      data: repository |> Map.from_struct()
    }
  end
end
