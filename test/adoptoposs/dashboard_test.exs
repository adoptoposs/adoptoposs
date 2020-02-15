defmodule Adoptoposs.DashboardTest do
  use Adoptoposs.DataCase

  import Adoptoposs.Factory
  alias Adoptoposs.Dashboard

  describe "project" do
    alias Adoptoposs.Dashboard.Project
    alias Adoptoposs.Network.Repository

    test "list_projects/1 returns the latest N projects" do
      insert(:project)
      other_project = insert(:project)

      assert Dashboard.list_projects(limit: 1) == [other_project]
    end

    test "list_projects/1 returns a user's projects" do
      project = insert(:project)
      assert Dashboard.list_projects(project.user) == [project]

      user = insert(:user)
      assert Dashboard.list_projects(user) == []
    end

    test "get_project!/1 returns the project with given id" do
      project = insert(:project)
      assert Dashboard.get_project!(project.id) == project
    end

    test "create_project/2 with valid data creates a project" do
      %{id: user_id} = insert(:user)
      %{id: repo_id} = repository = build(:repository)
      description = "description"
      attrs = %{user_id: user_id, description: description}

      assert {:ok, project} = Dashboard.create_project(repository, attrs)
      assert project = %Project{description: description, user_id: user_id, repo_id: repo_id}
    end

    test "create_project/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_project(%Repository{})
    end

    test "create_project/2 converts unique_constraint on user and project to error" do
      user = insert(:user)
      repository = build(:repository)
      insert(:project, user: user, repo_id: repository.id)
      attrs = %{user_id: user.id}

      assert {:error, changeset} = Dashboard.create_project(repository, attrs)
      assert assert [{:project, {"has already been taken", _}}] = changeset.errors
    end

    test "update_project/2 with valid data updates the project" do
      project = insert(:project)
      new_description = "new" <> project.description
      attrs = %{description: new_description}

      assert {:ok, %Project{} = project} = Dashboard.update_project(project, attrs)
      assert project.description == new_description
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = insert(:project)
      attrs = %{description: nil}

      assert {:error, %Ecto.Changeset{}} = Dashboard.update_project(project, attrs)
      assert project == Dashboard.get_project!(project.id)
    end

    test "delete_project/1 deletes the passed project" do
      project = insert(:project)
      assert {:ok, %Project{}} = Dashboard.delete_project(project)

      assert_raise Ecto.NoResultsError, fn ->
        Dashboard.get_project!(project.id)
      end
    end

    test "change_project/1 returns a project changeset" do
      project = insert(:project)
      assert %Ecto.Changeset{} = Dashboard.change_project(project)
    end
  end
end
