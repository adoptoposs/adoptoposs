defmodule Adoptoposs.Network.Github do
  alias Adoptoposs.Network.{Api, Repository}
  alias Adoptoposs.Network.Repository.{Commit, User, Language}

  @behaviour Api

  @api_uri "https://api.github.com/graphql"

  @impl Api
  def search_repos(token, query, limit) do
    query
    |> repo_search_query(limit)
    |> String.replace(~r/\s+/, " ")
    |> send_request(token)
    |> compile_repos()
    |> Enum.reject(&is_nil/1)
  end

  defp repo_search_query(query, limit) do
    ~s"""
    {
      search(query: \\\"is:public #{query}\\\", type: REPOSITORY, first: #{limit}) {
        edges {
          node {
            ... on Repository {
              name
              descriptionHTML
              url
              primaryLanguage {
                name
                color
              }
              owner {
                avatarUrl
                login
                url
              }
              issues(filterBy: {states: [OPEN]}) {
                totalCount
              }
              pullRequests(states: [OPEN]) {
                totalCount
              }
              stargazers {
                totalCount
              }
              watchers {
                totalCount
              }
              defaultBranchRef {
                target {
                  ... on Commit {
                    history(first: 1) {
                      edges {
                        node {
                          messageHeadline
                          authoredDate
                          author {
                            user {
                              url
                              name
                              avatarUrl
                              email
                              login
                            }
                          }
                          committer {
                            user {
                              url
                              name
                              avatarUrl
                              email
                              login
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    """
  end

  defp send_request(graphql_query, auth_token) do
    headers = [Authorization: "bearer #{auth_token}"]

    case HTTPoison.post(@api_uri, ~s({"query": "#{graphql_query}"}), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body, keys: :atoms)

      _ ->
        %{}
    end
  end

  defp compile_repos(%{data: %{search: %{edges: edges}}}) do
    Enum.map(edges, &(build_repository(&1.node) |> IO.inspect()))
  end

  defp compile_repos(_data), do: []

  defp build_repository(%{defaultBranchRef: branch} = data) do
    %Repository{
      name: data.name,
      description: data.descriptionHTML,
      url: data.url,
      star_count: data.stargazers.totalCount,
      watcher_count: data.watchers.totalCount,
      issue_count: data.issues.totalCount,
      pull_request_count: data.pullRequests.totalCount,
      owner: build_owner(data),
      last_commit: build_last_commit(branch),
      language: build_language(data)
    }
  end

  defp build_repository(_data), do: nil

  defp build_owner(%{owner: owner}) when not is_nil(owner) do
    %User{
      login: owner.login,
      avatar_url: owner.avatarUrl,
      profile_url: owner.url
    }
  end

  defp build_owner(_data), do: %User{}

  defp build_last_commit(%{target: %{history: %{edges: edges}}}) do
    last_commit =
      case edges do
        [head | _] -> head.node
        _ -> nil
      end

    {authored_at, author} =
      case last_commit do
        %{authoredDate: authored_date, author: %{user: author}, committer: %{user: committer}} ->
          user = committer || author || %{}

          case DateTime.from_iso8601(authored_date) do
            {:ok, date, _} -> {date, user}
            {:error, _} -> {nil, user}
          end

        _ ->
          {nil, %{}}
      end

    %Commit{
      authored_at: authored_at,
      author: %User{
        login: author[:login],
        name: author[:name],
        avatar_url: author[:avatarUrl],
        profile_url: author[:url],
        email: author[:email]
      }
    }
  end

  defp build_last_commit(_data), do: %Commit{}

  defp build_language(%{primaryLanguage: language}) when not is_nil(language) do
    struct(Language, language)
  end

  defp build_language(_data), do: %Language{}
end
