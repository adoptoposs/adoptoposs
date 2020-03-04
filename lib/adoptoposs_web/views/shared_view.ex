defmodule AdoptopossWeb.SharedView do
  use AdoptopossWeb, :view

  alias Adoptoposs.Network.Repository
  alias Adoptoposs.Dashboard.Project

  def project_url(%Project{} = project), do: project.data["url"]
  def project_url(%Repository{} = project), do: project.url

  def project_description(%Project{} = project), do: project.data["description"]
  def project_description(%Repository{} = project), do: project.description
end
