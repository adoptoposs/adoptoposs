defmodule AdoptopossWeb.SharedViewTest do
  use AdoptopossWeb.ConnCase, async: true

  import Adoptoposs.Factory

  alias AdoptopossWeb.SharedView

  describe "project_name/1" do
    test "returns the full organization/project name when passing a Project" do
      organization = "organization-name"
      project_name = "project-name"
      project = build(:project, data: %{"owner" => %{"login" => organization}}, name: project_name)
      assert SharedView.project_name(project) == "#{organization}/#{project_name}"
    end

    test "returns the name when passing a Repository" do
      name = "repository-name"
      repository = build(:repository, name: name)
      assert SharedView.project_name(repository) == name
    end
  end

  describe "project_url/1" do
    test "returns the project data url when passing a Project" do
      url = "https://example.com"
      project = build(:project, data: %{"url" => url})
      assert SharedView.project_url(project) == url
    end

    test "returns the repository url when passing a Repository" do
      url = "https://example.com"
      repository = build(:repository, url: url)
      assert SharedView.project_url(repository) == url
    end
  end

  describe "count/2" do
    test "returns number with passed word if number == 1" do
      assert SharedView.count("thing", count: 1) == "1 thing"
    end

    test "returns number with pluralized word if number > 1" do
      assert SharedView.count("thing", count: 2) == "2 things"
    end

    test "returns passed word prefixed with 'no' if number < 1" do
      assert SharedView.count("thing", count: 0) == "no things"
      assert SharedView.count("thing", count: -1) == "no things"
    end
  end
end
