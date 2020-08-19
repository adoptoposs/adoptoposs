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
    find_projects(query, offset: offset, limit: limit, filters: [])
  end

  def find_projects(query, offset: offset, limit: limit, filters: filters)
      when is_binary(query) do
    terms = Regex.split(~r/[\s\.-_]/, String.downcase(query))
    base_query = projects_base_query(terms, filters)

    results =
      base_query
      |> offset(^offset)
      |> limit(^limit)
      |> order_by(desc: :updated_at)
      |> order_by([:name, :repo_owner])
      |> preload([:user, :language, :interests])
      |> Repo.all()

    %{results: results, total_count: base_query |> Repo.aggregate(:count)}
  end

  def find_projects(_query, _opts), do: %{results: [], total_count: 0}

  defp projects_base_query(terms, []) do
    Project
    |> join(:left, [p], t in assoc(p, :language))
    |> where(status: ^:published)
    |> where_all_terms_match(terms, &matches_project/2)
  end

  defp projects_base_query(terms, filters) do
    Project
    |> join(:left, [p], t in assoc(p, :language))
    |> where(status: ^:published)
    |> where_all_terms_match(terms, &matches_project/2)
    |> where([p], p.language_id in ^filters)
  end

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
          ilike(project.repo_description, ^"%#{term}%") or
          ilike(project.description, ^"%#{term}%")
  end

  def matches_tag(term, query) do
    from project in query,
      where: ilike(project.name, ^"%#{term}%")
  end
end
