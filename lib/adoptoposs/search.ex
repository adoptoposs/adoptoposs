defmodule Adoptoposs.Search do
  @moduledoc """
  The search context provides functions for finding projects by language tag,
  and name.
  """

  import Ecto.Query, warn: false

  alias Adoptoposs.Repo
  alias Adoptoposs.Dashboard.Project
  alias Adoptoposs.Tags.Tag

  def find_projects(query, offset: offset, limit: limit) do
    terms = Regex.split(~r/[\s\.-_]/, String.downcase(query))

    Project
    |> where_all_terms_match(terms, &matches_project/2)
    |> offset(^offset)
    |> limit(^limit)
    |> order_by(desc: :updated_at)
    |> order_by(:name)
    |> preload([:user, :interests])
    |> Repo.all()
  end

  def find_tags(query, offset: offset, limit: limit) do
    terms = Regex.split(~r/[\s\.-_]/, String.downcase(query))

    Tag
    |> where_all_terms_match(terms, &matches_tag/2)
    |> offset(^offset)
    |> limit(^limit)
    |> order_by(:name)
    |> Repo.all()
  end

  defp where_all_terms_match(query, terms, fun) do
    Enum.reduce(terms, query, fun)
  end

  def matches_project(term, query) do
    from p in query,
      where: ilike(p.name, ^"%#{term}%") or ilike(p.language, ^"%#{term}%")
  end

  def matches_tag(term, query) do
    from p in query,
      where: ilike(p.name, ^"%#{term}%")
  end
end
