defmodule Adoptoposs.ProjectsTest do
  use ExUnit.Case, async: true

  import Adoptoposs.Factory
  alias Adoptoposs.Projects

  describe "score" do
    test "returns a high value if the repo is popular but was recently updated" do
      commit = build(:commit, authored_at: DateTime.utc_now())

      repo =
        build(:repository,
          last_commit: commit,
          star_count: 10_000,
          watcher_count: 1_000,
          issue_count: 100,
          pull_request_count: 100
        )

      assert Projects.score(repo) > 0.5
    end

    test "returns a high value if the the repo is not popular and was rencently updated" do
      commit = build(:commit, authored_at: DateTime.utc_now())

      repo =
        build(:repository,
          last_commit: commit,
          star_count: 0,
          watcher_count: 0,
          issue_count: 1_000,
          pull_request_count: 1_000
        )

      assert Projects.score(repo) > 0.5
    end

    test "returns a low value if the repo is popular, has high pr/issues and was not updated recently" do
      commit = build(:commit, authored_at: Timex.shift(DateTime.utc_now(), years: -1))

      repo =
        build(:repository,
          last_commit: commit,
          star_count: 10_000,
          watcher_count: 1_000,
          issue_count: 100,
          pull_request_count: 100
        )

      assert Projects.score(repo) < 0.5
    end

    test "returns a value between 0.0 and 1.0 else" do
      commit = build(:commit, authored_at: Timex.shift(DateTime.utc_now(), months: -5))

      repo =
        build(:repository,
          last_commit: commit,
          star_count: 100,
          watcher_count: 100,
          issue_count: 10,
          pull_request_count: 10
        )

      score = Projects.score(repo)

      assert 0.0 < score and score < 1.0
    end
  end
end
