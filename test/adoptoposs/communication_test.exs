defmodule Adoptoposs.CommunicationTest do
  use Adoptoposs.DataCase

  import Adoptoposs.Factory

  alias Adoptoposs.Communication

  describe "policy" do
    test "create_interest is permitted for other user’s projects" do
      user = build(:user, id: 1)
      project = build(:project, user_id: 2)

      assert :ok = Bodyguard.permit(Communication, :create_interest, user, project)
    end

    test "create_interest is forbidden for own projects" do
      user = build(:user, id: 1)
      project = build(:project, user_id: user.id)

      assert {:error, :unauthorized} =
               Bodyguard.permit(Communication, :create_interest, user, project)
    end
  end

  describe "interests" do
    alias Adoptoposs.Communication.Interest

    test "list_user_interests/1 returns all interests of a user" do
      user = insert(:user)
      interest = insert(:interest, creator: user)

      assert Communication.list_user_interests(user) |> Enum.map(& &1.id) == [interest.id]
      assert Communication.list_user_interests(user.id) |> Enum.map(& &1.id) == [interest.id]
      assert Communication.list_user_interests(-1) == []
    end

    test "list_project_interests/1 returns all interests for a project" do
      project = insert(:project)
      interest = insert(:interest, project: project)

      assert Communication.list_project_interests(project)
             |> Enum.map(& &1.id) == [interest.id]

      assert Communication.list_project_interests(project.id)
             |> Enum.map(& &1.id) == [interest.id]

      assert Communication.list_project_interests(-1) == []
    end

    test "get_interest!/1 returns the interest with given id" do
      interest = insert(:interest)
      assert Communication.get_interest!(interest.id).id == interest.id
    end

    test "create_interest/1 with valid data creates a interest" do
      creator = insert(:user)
      project = insert(:project)
      attrs = %{creator_id: creator.id, project_id: project.id, message: "Hi!"}

      assert {:ok, %Interest{} = interest} = Communication.create_interest(attrs)
    end

    test "create_interest/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communication.create_interest(%{})
    end

    test "create_interest/1 for existing interest returns error changeset" do
      interest = insert(:interest)
      attrs = %{creator_id: interest.creator_id, project_id: interest.project_id}
      assert {:error, %Ecto.Changeset{}} = Communication.create_interest(attrs)
    end

    test "delete_interest/1 deletes the interest" do
      interest = insert(:interest)
      assert {:ok, %Interest{}} = Communication.delete_interest(interest)
      assert_raise Ecto.NoResultsError, fn -> Communication.get_interest!(interest.id) end
    end
  end
end
