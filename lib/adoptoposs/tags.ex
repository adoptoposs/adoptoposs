defmodule Adoptoposs.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query, warn: false
  alias Adoptoposs.Repo

  alias Adoptoposs.Accounts.User
  alias Adoptoposs.Tags.{Tag, TagSubscription}

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_language_tags do
    Tag
    |> where(type: ^Tag.Language.type())
    |> Repo.all()
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Gets a single tag by its name.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag_by_name!("some-name")
      %Tag{}

      iex> get_tag_by_name!(nil)
      %Tag{name: "unknown"}

      iex> get_tag_by_name!("not exisiting")
      ** (Ecto.NoResultsError)
  """
  def get_tag_by_name!(nil) do
    unknown_tag = Tag.Utility.unknown()
    get_tag_by_name!(unknown_tag.name)
  end

  def get_tag_by_name!(name) do
    from(t in Tag, where: fragment("lower(?) = lower(?)", t.name, ^name))
    |> Repo.one!()
  end

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  @doc """
  Inserts or updates multiple tags.

  ## Examples

      iex> change_tag(attrs)
      %Ecto.Changeset{source: %Tag{}}
  """
  def upsert_tags(tag_data \\ []) do
    tag_data |> Enum.map(&upsert_tag/1)
  end

  defp upsert_tag(%{name: name} = attrs) do
    case get_tag(name) do
      nil -> %Tag{}
      tag -> tag
    end
    |> Tag.changeset(attrs)
    |> Repo.insert_or_update()
  end

  defp get_tag(name) when is_binary(name) do
    Tag
    |> where(name: ^name)
    |> Repo.one()
  end

  @doc """
  Returns the list of all tag subscriptions of a user.

  ## Examples

      iex> list_user_tag_subscriptions(user)
      [%TagSubscription{}, ...]

  """
  def list_user_tag_subscriptions(%User{} = user) do
    user
    |> Ecto.assoc(:tag_subscriptions)
    |> preload(:tag)
    |> order_by(:inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the tag subscription for the given user and tag.

  ## Examples

      iex> get_tag_subscription(id)
      %TagSubscription{}

      iex> get_tag_subscription(-1)
      ** (Ecto.NoResultsError)

  """
  def get_tag_subscription!(id), do: Repo.get!(TagSubscription, id)

  @doc """
  Creates a subscription to a tag for a user.

  ## Examples

      iex> create_tag_subscription(%{user_id: 1, tag_id: 1})
      {:ok, %TagSubscription{}}

      iex> create_tag_subscription(%{field: "bad value"})
      {:error, %Ecto.Changeset{}}
  """
  def create_tag_subscription(attrs \\ []) do
    %TagSubscription{}
    |> TagSubscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes the tag subscription.

  ## Examples

      iex> delete_tag_subscription(tag_subscription)
      {:ok, %TagSubscription{}}

      iex> delete_tag_subscription(%TagSubscription{})
      {:error, %Ecto.Changeset{}}
  """
  def delete_tag_subscription(%TagSubscription{} = tag_subscription) do
    Repo.delete(tag_subscription)
  end
end
