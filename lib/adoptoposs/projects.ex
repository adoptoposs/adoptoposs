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

    interest = 1 - sigmoid(:math.log10(stars / 100))
    pr_need = 1 - sigmoid(:math.log10(prs / 10))
    issue_need = 1 - sigmoid(:math.log10(issues / 10))
    pressure = 1 - sigmoid(:math.log10(watchers / 10))

    meassures = [interest, pr_need, issue_need, pressure]
    Enum.sum(meassures) / Enum.count(meassures)
  end

  defp maintainer_activity(%Repository{} = %{last_commit: %{authored_at: date}}) do
    now = DateTime.utc_now()
    days = max(Timex.diff(now, date || now, :days), 1)
    sigmoid(:math.log10(days / 30))
  end

  defp sigmoid(x), do: 1 / (1 + :math.exp(-x))

  def filter(repos, type = "maintainer"), do: filter_unmaintained(repos)
  def filter(repos, type = "help"), do: filter_help_needed(repos)
  def filter(repos, type), do: []

  def filter_unmaintained(repos) do
    repos |> Enum.filter(&need_maintainer?/1)
  end

  def filter_help_needed(repos) do
    repos |> Enum.filter(&need_help?/1)
  end

  defp need_maintainer?(%Repository{} = repo) do
    score(repo) < 0.33
  end

  defp need_help?(%Repository{} = repo) do
    value = score(repo)
    value >= 0.33 && value < 0.66
  end
end
