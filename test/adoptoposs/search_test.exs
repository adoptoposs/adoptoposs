defmodule Adoptoposs.SearchTest do
  use Adoptoposs.DataCase

  import Adoptoposs.Factory
  alias Adoptoposs.Search
  alias Adoptoposs.Tags.Tag

  describe "search" do
    test "find_projects/2 returns the matching projects by language" do
      project_1 = insert(:project, language: build(:tag, name: "Elixir"))
      project_2 = insert(:project, name: "Pixi")
      project_3 = insert(:project, repo_owner: "FIXIT")

      insert(:project, language: build(:tag, name: "Ruby"))
      insert(:project, language: build(:tag, name: "JavaScript"))

      query = "IXi"

      projects = Search.find_projects(query, offset: 0, limit: 3)

      for project <- projects do
        assert %Tag{} = project.language
      end

      assert [project_2.id, project_1.id, project_3.id] == projects |> Enum.map(& &1.id)

      projects = Search.find_projects(query, offset: 0, limit: 1)
      assert [project_2.id] == projects |> Enum.map(& &1.id)

      projects = Search.find_projects(query, offset: 1, limit: 1)
      assert [project_1.id] == projects |> Enum.map(& &1.id)

      projects = Search.find_projects(query, offset: 2, limit: 1)
      assert [project_3.id] == projects |> Enum.map(& &1.id)

      projects = Search.find_projects(query, offset: 3, limit: 1)
      assert [] == projects
    end

    test "find_projects/2 with a not binary query returns empty list" do
      assert [] == Search.find_projects(nil, offset: 0, limit: 1)
      assert [] == Search.find_projects([], offset: 0, limit: 1)
      assert [] == Search.find_projects(%{}, offset: 0, limit: 1)
    end

    test "find_tags/2 returns the matching tags" do
      tag_1 = insert(:tag, name: "Java", type: Tag.Language.type())
      tag_2 = insert(:tag, name: "JavaScript", type: Tag.Language.type())
      insert(:tag, name: "Elixir", type: Tag.Language.type())
      insert(:tag, name: "JaJa")

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

    test "find_tags/2 with a not binary query returns empty list" do
      assert [] == Search.find_tags(nil, offset: 0, limit: 1)
      assert [] == Search.find_tags([], offset: 0, limit: 1)
      assert [] == Search.find_tags(%{}, offset: 0, limit: 1)
    end
  end
end
