defmodule Adoptoposs.Communication do
  @moduledoc """
  The Communication context.
  """

  import Ecto.Query, warn: false
  alias Adoptoposs.Repo

  alias Adoptoposs.Communication.{Interest, Policy}
  alias Adoptoposs.Accounts.User
  alias Adoptoposs.Dashboard.Project

  defdelegate authorize(action, user, params), to: Policy

  @doc """
  Returns the list of interests of a user.

  ## Examples

      iex> list_user_interests(%User{})
      [%Interest{}, ...]

      iex> list_user_interests(1)
      [%Interest{}, ...]

  """
  def list_user_interests(%User{} = user) do
    user
    |> Ecto.assoc(:interests)
    |> preload(:creator)
    |> preload(project: [:user, :language])
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def list_user_interests(user_id) when is_integer(user_id) do
    Interest
    |> where(creator_id: ^user_id)
    |> preload(:creator)
    |> preload(project: :user)
    |> Repo.all()
  end

  @doc """
  Returns the list of interests for a project.

  ## Examples

      iex> list_project_interests(%Project{})
      [%Interest{}, ...]

      iex> list_project_interests(1)
      [%Interest{}, ...]

  """
  def list_project_interests(%Project{} = project) do
    project
    |> Ecto.assoc(:interests)
    |> preload(:creator)
    |> preload(project: :user)
    |> Repo.all()
  end

  def list_project_interests(project_id) when is_integer(project_id) do
    Interest
    |> where(project_id: ^project_id)
    |> preload(:creator)
    |> preload(project: :user)
    |> Repo.all()
  end

  @doc """
  Gets a single interest.

  Raises `Ecto.NoResultsError` if the Interest does not exist.

  ## Examples

      iex> get_interest!(123)
      %Interest{}

      iex> get_interest!(456)
      ** (Ecto.NoResultsError)

  """
  def get_interest!(id) do
    Interest
    |> preload(:creator)
    |> preload(project: :user)
    |> Repo.get!(id)
  end

  @doc """
  Creates a interest.

  ## Examples

      iex> create_interest(%{field: value})
      {:ok, %Interest{}}

      iex> create_interest(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_interest(attrs \\ %{}) do
    %Interest{}
    |> Interest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a interest.

  ## Examples

      iex> delete_interest(interest)
      {:ok, %Interest{}}

      iex> delete_interest(interest)
      {:error, %Ecto.Changeset{}}

  """
  def delete_interest(%Interest{} = interest) do
    Repo.delete(interest)
  end
end
