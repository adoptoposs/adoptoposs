defmodule Adoptoposs.Projects do
  alias Adoptoposs.Network.Repository

  @community_activity_weight 0.1
  @maintainer_activity_weight 0.9

  @doc """
  The score describes a meassure for how well a repository is maintained.

  It takes the community's activity, as well as the maintainers activity
  (when was the repo last updated) into account and calculates a weighted
  score from these parts.

  - maintainer activity ~ score
  - 1 / community_activity ~ score

  """
  def score(%Repository{} = %{issue_count: issues, pull_request_count: prs})
      when issues == 0 and prs == 0,
      do: 1.0

  def score(%Repository{} = repo) do
    community = community_activity(repo) * @community_activity_weight
    maintainer = maintainer_activity(repo) * @maintainer_activity_weight
    1 - (community + maintainer)
  end

  defp community_activity(%Repository{} = repo) do
    %{star_count: stars, watcher_count: watchers, issue_count: issues, pull_request_count: prs} =
      repo

    stars = max(stars, 1)
    issues = max(issues, 1)
    watchers = max(watchers, 1)
    prs = max(prs, 1)

    interest = sigmoid(:math.log10(stars / 100))
    pr_need = sigmoid(:math.log10(prs / 10))
    issue_need = sigmoid(:math.log10(issues / 10))
    pressure = sigmoid(:math.log10(watchers / 10))

    meassures = [interest, pr_need, issue_need, pressure]
    Enum.sum(meassures) / Enum.count(meassures)
  end

  def maintainer_activity(%Repository{} = %{last_commit: %{authored_at: date}}) do
    now = DateTime.utc_now()
    days = max(Timex.diff(now, date || now, :days), 1)
    sigmoid(:math.log10(days / 30))
  end

  defp sigmoid(x), do: 1 / (1 + :math.exp(-x))
end
