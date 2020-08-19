defmodule Adoptoposs.UpdateReposityData do
  @moduledoc """
  Update project repo data by fetching the repository data for each Project
  from the respective provider.
  """

  import Ecto.Query, only: [from: 2]
  alias Adoptoposs.{Repo, Submissions, Submissions.Project, Network, Tags}

  @batch_size 100

  @doc """
  Run project update from provider repos.

  Fetching the data from the provider API is done in batches of `@batch_size`,
  because e.g. GitHub allows only batches of maximum 100 ids.
  """
  def run(provider: provider, token: token) do
    Repo
    |> stream(from(p in Project, select: [p.id, p.repo_id], order_by: p.updated_at))
    |> Enum.each(& run_batch(&1, provider: provider, token: token))
  end

  defp run_batch(project_data, provider: provider, token: token) do
    project_ids = project_data |> Enum.map(&List.first(&1))
    repo_ids = project_data |> Enum.map(&List.last(&1))

    with {:ok, repositories} <- Network.repos(token, provider, repo_ids) do
      project_ids
      |> Enum.with_index()
      |> Enum.map(fn {id, index} -> update_data(id, repositories |> Enum.at(index)) end)
    else
      {:error, error} ->
        IO.inspect(error)
    end
  end

  defp update_data(project_id, %Network.Repository{} = repository) do
    project = Submissions.get_project!(project_id)

    if project.repo_id == repository.id do
      %{id: language_id} = Tags.get_tag_by_name!(repository.language.name)
      Submissions.update_project_data(project, repository, %{language_id: language_id})

      # setting 1 second timeout in order to keep the updated_at order of projects
      :timer.sleep(1000)
    end
  end

  defp update_data(_project_id, _repository), do: nil

  defp stream(repo, query, batch_size \\ @batch_size) do
    Stream.unfold(0, fn
      :done ->
        nil

      offset ->
        results = repo.all(from _ in query, offset: ^offset, limit: ^batch_size)
        state = if length(results) < batch_size, do: :done, else: offset + batch_size
        { results, state }
    end)
  end
end

# Takes provider and API token as command line arguments,
# so that it can be run as:
#
#    $ mix run run priv/repo/update_repo_data.exs github <api-token>
#
# or with the mix alias:
#
#    $ mix update.github_repos <api-token>
#
{[provider: provider, token: token], [], []} = OptionParser.parse(System.argv(), strict: [provider: :string, token: :string])
Adoptoposs.UpdateReposityData.run(provider: provider, token: token)
