defmodule Adoptoposs.Projects do
  alias Adoptoposs.Network.Repository

  @stars_weight 0.7
  @watchers_weight 0.3
  @community_activity_weight 0.1
  @maintainer_activity_weight 0.9

  @doc """
  The score describes a meassure for how well a repository is maintained.

  It takes the community_activity and the community's activity, as well as the
  maintainers activity (when was the repo last updated) into account and
  calculates a weighted score from these parts.

  - maintainer activity ~ score
  - 1 / community_activity ~ score

  """
  def score(%Repository{} = %{issue_count: issues, pull_request_count: prs})
      when issues == 0 and prs == 0,
      do: 1.0

  def score(%Repository{} = repo) do
    community_activity_score = community_activity(repo)
    maintainer_activity_score = maintainer_activity(repo)

    community_activity_score * @community_activity_weight +
      maintainer_activity_score * @maintainer_activity_weight
  end

  defp community_activity(%Repository{} = repo) do
    %{star_count: stars, watcher_count: watchers, issue_count: issues, pull_request_count: prs} =
      repo

    stars = max(stars, 1)
    issues = max(issues, 1)
    watchers = max(watchers, 1)
    prs = max(prs, 1)

    1 / (stars / issues) * @stars_weight + 1 / (watchers / prs) * @watchers_weight
  end

  def maintainer_activity(%Repository{} = %{last_commit: %{authored_at: date}}) do
    now = DateTime.utc_now()
    1 / max(Timex.diff(now, date || now, :weeks), 1)
  end
end
