defmodule Adoptoposs.DashboardTest do
  use Adoptoposs.DataCase

  import Adoptoposs.Factory

  alias Adoptoposs.Dashboard

  describe "policy" do
    test "update_project is permitted for own projects" do
      user = build(:user, id: 1)
      project = build(:project, user_id: user.id)

      assert :ok = Bodyguard.permit(Dashboard, :update_project, user, project)
    end

    test "update_project is forbidden for other user’s projects" do
      user = build(:user, id: 1)
      project = build(:project, user_id: 2)

      assert {:error, :unauthorized} = Bodyguard.permit(Dashboard, :update_project, user, project)
    end

    test "delete_project is permitted for own projects" do
      user = build(:user, id: 1)
      project = build(:project, user_id: user.id)

      assert :ok = Bodyguard.permit(Dashboard, :delete_project, user, project)
    end

    test "delete_project is forbidden for other user’s projects" do
      user = build(:user, id: 1)
      project = build(:project, user_id: 2)

      assert {:error, :unauthorized} = Bodyguard.permit(Dashboard, :delete_project, user, project)
    end

    test "show_project is permitted for own projects" do
      user = build(:user, id: 1)
      project = build(:project, user_id: user.id)

      assert :ok = Bodyguard.permit(Dashboard, :show_project, user, project)
    end

    test "show_project is forbidden for other user’s projects" do
      user = build(:user, id: 1)
      project = build(:project, user_id: 2)

      assert {:error, :unauthorized} = Bodyguard.permit(Dashboard, :show_project, user, project)
    end
  end

  describe "project" do
    alias Adoptoposs.Dashboard.Project
    alias Adoptoposs.Network.Repository
    alias Adoptoposs.Tags.Tag

    test "list_projects/1 returns the latest N projects" do
      insert(:project)
      other_project = insert(:project)

      projects = Dashboard.list_projects(limit: 1)
      assert projects |> Enum.map(& &1.id) == [other_project.id]

      [project | _] = projects
      assert %Tag{} = project.language
    end

    test "list_projects/1 returns a user's projects" do
      project = insert(:project)
      projects = Dashboard.list_projects(project.user)
      assert projects |> Enum.map(& &1.id) == [project.id]
      assert %Tag{} = List.first(projects).language

      user = insert(:user)
      assert Dashboard.list_projects(user) == []
    end

    test "get_project!/1 return the project with the given id" do
      project = insert(:project)
      assert Dashboard.get_project!(project.id).id == project.id
    end

    test "get_project!/1 raises error when the project does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Dashboard.get_project!(-1)
      end
    end

    test "get_user_project/2 returns the project with given id" do
      user = insert(:user)
      project = insert(:project, user: user)
      assert Dashboard.get_user_project(user, project.id).id == project.id
    end

    test "get_user_project/2 returns nil for a non-user project" do
      user = insert(:user)
      project = insert(:project)
      refute Dashboard.get_user_project(user, project.id)
    end

    test "create_project/2 with valid data creates a project" do
      %{id: user_id} = insert(:user)
      %{id: repo_id} = repository = build(:repository)
      %{id: tag_id} = insert(:tag)
      description = "description"
      attrs = %{user_id: user_id, description: description, language_id: tag_id}

      assert {:ok, project} = Dashboard.create_project(repository, attrs)

      assert project = %Project{
               description: description,
               user_id: user_id,
               repo_id: repo_id,
               language_id: tag_id
             }
    end

    test "create_project/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_project(%Repository{})
    end

    test "create_project/2 converts unique_constraint on user and project to error" do
      user = insert(:user)
      tag = insert(:tag)
      repository = build(:repository)
      insert(:project, user: user, language: tag, repo_id: repository.id)
      attrs = %{user_id: user.id, language_id: tag.id}

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
      assert project.id == Dashboard.get_user_project(project.user, project.id).id
    end

    test "delete_project/1 deletes the passed project" do
      project = insert(:project)
      assert {:ok, %Project{}} = Dashboard.delete_project(project)
      refute Dashboard.get_user_project(project.user, project.id)
    end

    test "change_project/1 returns a project changeset" do
      project = insert(:project)
      assert %Ecto.Changeset{} = Dashboard.change_project(project)
    end
  end
end
