defmodule Adoptoposs.Search do
  @moduledoc """
  The search context provides functions for finding projects by language tag,
  and name.
  """

  import Ecto.Query, warn: false

  alias Adoptoposs.Repo
  alias Adoptoposs.Submissions.Project
  alias Adoptoposs.Tags.Tag

  def find_projects(query, offset: offset, limit: limit) when is_binary(query) do
    terms = Regex.split(~r/[\s\.-_]/, String.downcase(query))

    Project
    |> join(:left, [p], t in assoc(p, :language))
    |> where_all_terms_match(terms, &matches_project/2)
    |> offset(^offset)
    |> limit(^limit)
    |> order_by(desc: :updated_at)
    |> order_by([:name, :repo_owner])
    |> preload([:user, :language, :interests])
    |> Repo.all()
  end

  def find_projects(_query, _opts), do: []

  def find_tags(query, offset: offset, limit: limit) when is_binary(query) do
    terms = Regex.split(~r/[\s\.-_]/, String.downcase(query))

    Tag
    |> where(type: ^Tag.Language.type())
    |> where_all_terms_match(terms, &matches_tag/2)
    |> offset(^offset)
    |> limit(^limit)
    |> order_by(:name)
    |> Repo.all()
  end

  def find_tags(_query, _opts), do: []

  defp where_all_terms_match(query, terms, fun) do
    Enum.reduce(terms, query, fun)
  end

  def matches_project(term, query) do
    from [project, tag] in query,
      where:
        ilike(project.name, ^"%#{term}%") or
          ilike(project.repo_owner, ^"%#{term}%") or
          ilike(tag.name, ^"%#{term}%")
  end

  def matches_tag(term, query) do
    from project in query,
      where: ilike(project.name, ^"%#{term}%")
  end
end
