defmodule AdoptopossWeb.ProjectViewTest do
  use AdoptopossWeb.ConnCase, async: true

  import Adoptoposs.Factory

  alias AdoptopossWeb.ProjectView

  test "can_be_contacted?/2 returns false if the passed user_id is nil" do
    project = build(:project)
    refute ProjectView.can_be_contacted?(project, nil)
  end

  test "can_be_contacted?/2 returns false if the passed project is nil" do
    refute ProjectView.can_be_contacted?(nil, 1)
  end

  test "can_be_contacted?/2 returns true if the passed project has an interest of the user" do
    user = build(:user, id: 1)
    interest = build(:interest, creator_id: user.id)
    project = build(:project, interests: [interest])

    assert ProjectView.can_be_contacted?(project, user.id)
  end

  test "can_be_contacted?/2 returns false if the passed project was created by the user" do
    user = build(:user, id: 1)
    project = build(:project, user_id: user.id)

    refute ProjectView.can_be_contacted?(project, user.id)
  end

  test "can_be_contacted?/2 returns true for a project that is not created by the user" do
    user = build(:user, id: 1)
    project = build(:project)

    assert ProjectView.can_be_contacted?(project, user.id)
  end

  test "contacted?/2 returns false if the project or user_id is nil" do
    refute ProjectView.contacted?(nil, 1)
    refute ProjectView.contacted?(build(:project), nil)
  end

  test "contacted?/2 returns false if the project was created by the user" do
    user = build(:user, id: 1)
    project = build(:project, user_id: user.id)

    refute ProjectView.contacted?(project, user.id)
  end

  test "contacted?/2 returns false if the project has no interest of the user yet" do
    user = build(:user, id: 1)
    interest = build_list(2, :interest)
    project = build(:project, interests: interest)

    refute ProjectView.contacted?(project, user.id)
  end

  test "contacted?/2 returns true if the project has an interest of the user" do
    user = build(:user, id: 1)
    interest = build(:interest, creator_id: user.id)
    project = build(:project, interests: [interest])

    assert ProjectView.contacted?(project, user.id)
  end
end
