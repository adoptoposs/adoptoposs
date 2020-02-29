defmodule Adoptoposs.SearchTest do
  use Adoptoposs.DataCase

  import Adoptoposs.Factory
  alias Adoptoposs.Search

  describe "search" do
    test "find_projects/2 returns the matching projects by language" do
      project_1 = insert(:project, language: "Elixir")
      project_2 = insert(:project, name: "Pixi")
      insert(:project, language: "Ruby")
      insert(:project, language: "JavaScript")

      query = "IXi"

      projects = Search.find_projects(query, offset: 0, limit: 2)
      assert [project_2.id, project_1.id] == projects |> Enum.map(& &1.id)

      projects = Search.find_projects(query, offset: 0, limit: 1)
      assert [project_2.id] == projects |> Enum.map(& &1.id)

      projects = Search.find_projects(query, offset: 1, limit: 1)
      assert [project_1.id] == projects |> Enum.map(& &1.id)

      projects = Search.find_projects(query, offset: 2, limit: 1)
      assert [] == projects
    end

    test "find_tags/2 returns the matching tags" do
      tag_1 = insert(:tag, name: "Java")
      tag_2 = insert(:tag, name: "JavaScript")
      insert(:tag, name: "Elixir")

      query = "jA"

      tags = Search.find_tags(query, offset: 0, limit: 2)
      assert [tag_1, tag_2] == tags

      tags = Search.find_tags(query, offset: 0, limit: 1)
      assert [tag_1] == tags

      tags = Search.find_tags(query, offset: 1, limit: 1)
      assert [tag_2] == tags

      tags = Search.find_tags(query, offset: 2, limit: 1)
      assert [] == tags
    end
  end
end
