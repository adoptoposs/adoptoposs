defmodule AdoptopossWeb.ProjectView do
  use AdoptopossWeb, :view

  alias Adoptoposs.Dashboard.Project

  def can_be_contacted?(%Project{user_id: user_id}, user_id), do: false
  def can_be_contacted?(nil, _), do: false
  def can_be_contacted?(_, nil), do: false
  def can_be_contacted?(%Project{}, _), do: true

  def contacted?(%Project{user_id: user_id}, user_id), do: false
  def contacted?(%Project{}, nil), do: false
  def contacted?(nil, _), do: false

  def contacted?(%Project{} = project, user_id) do
    user_id in Enum.map(project.interests, & &1.creator_id)
  end
end
