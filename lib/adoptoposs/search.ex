defmodule Adoptoposs.Search do
  @moduledoc """
  The search context provides functions for finding projects by language tag,
  and name.
  """

  import Ecto.Query, warn: false

  alias Adoptoposs.Repo
  alias Adoptoposs.Dashboard.Project

  def find_projects(query, offset: offset, limit: limit) do
    terms = Regex.split(~r/[\s\.-_]/, String.downcase(query))

    Project
    |> where_all_terms_match(terms)
    |> offset(^offset)
    |> limit(^limit)
    |> order_by(desc: :updated_at)
    |> order_by(:name)
    |> preload(:user)
    |> Repo.all()
  end

  def where_all_terms_match(query, terms) do
    Enum.reduce(terms, query, &and_where_term_matches/2)
  end

  def and_where_term_matches(term, query) do
    from p in query,
      where: ilike(p.name, ^"%#{term}%") or ilike(p.language, ^"%#{term}%")
  end
end
