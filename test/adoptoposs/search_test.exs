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

      projects = Search.find_projects("IXi", offset: 0, limit: 2)
      assert [project_2.id, project_1.id] == projects |> Enum.map(& &1.id)

      projects = Search.find_projects("IXi", offset: 0, limit: 1)
      assert [project_2.id] == projects |> Enum.map(& &1.id)

      projects = Search.find_projects("IXi", offset: 1, limit: 1)
      assert [project_1.id] == projects |> Enum.map(& &1.id)
    end
  end
end
