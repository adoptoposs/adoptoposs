defmodule AdoptopossWeb.SharedView do
  use AdoptopossWeb, :view

  alias Adoptoposs.Network.Repository
  alias Adoptoposs.Submissions.Project

  def project_name(%Project{} = project) do
    "#{project.data["owner"]["login"]}/#{project.name}"
  end

  def project_name(%Repository{} = project) do
    project.name
  end

  def project_url(%Project{} = project), do: project.data["url"]
  def project_url(%Repository{} = project), do: project.url

  def project_description(%Project{} = project), do: String.trim(project.repo_description)
  def project_description(%Repository{} = project), do: String.trim(project.description)

  def count(word, count: count) when count < 1, do: "no #{word}s"
  def count(word, count: count) when count == 1, do: "#{count} #{word}"
  def count(word, count: count) when count > 1, do: "#{count} #{word}s"
end
