defmodule Adoptoposs.Network.Api.Github do
  alias Adoptoposs.Network.{Api, Repository, PageInfo, Organization}
  alias Adoptoposs.Network.Repository.{Commit, User, Language}

  @behaviour Api

  @api_uri "https://api.github.com/graphql"

  @impl Api
  def organizations(token, limit, after_cursor) do
    organizations_query(limit, after_cursor)
    |> send_request(token)
    |> compile_organizations()
  end

  @impl Api
  def repos(token, organization, limit, after_cursor) do
    repos_query(organization, limit, after_cursor)
    |> send_request(token)
    |> compile_repos()
  end

  @impl Api
  def user_repos(token, limit, after_cursor) do
    user_repos_query(limit, after_cursor)
    |> send_request(token)
    |> compile_user_repos()
  end

  defp organizations_query(limit, after_cursor) do
    params = pagination_params(limit, after_cursor)

    ~s"""
    {
      viewer {
        organizations(#{params}) {
          pageInfo {
            hasNextPage
            endCursor
          }
          edges {
            node {
              login
              name
              description
              avatarUrl
              viewerCanAdminister
            }
          }
        }
      }
    }
    """
  end

  defp repos_query(organization, limit, after_cursor) do
    params = pagination_params(limit, after_cursor)

    ~s"""
    {
      viewer {
        organization(login: \\\"#{organization}\\\") {
          repositories(#{params} isFork: false privacy: PUBLIC orderBy: {field: UPDATED_AT, direction: DESC}) {
            pageInfo {
              hasNextPage
              endCursor
            }
            edges {
              node {
                id
                name
                viewerCanAdminister
                descriptionHTML
                url
                primaryLanguage {
                  name
                  color
                }
                owner {
                  login
                  avatarUrl
                  url
                }
              }
            }
          }
        }
      }
    }
    """
  end

  defp user_repos_query(limit, after_cursor) do
    params = pagination_params(limit, after_cursor)

    ~s"""
    {
      viewer {
        repositories(#{params} isFork: false privacy: PUBLIC orderBy: {field: UPDATED_AT, direction: DESC}) {
          pageInfo {
            hasNextPage
            endCursor
          }
          edges {
            node {
              id
              name
              viewerCanAdminister
              descriptionHTML
              url
              primaryLanguage {
                name
                color
              }
              owner {
                login
                avatarUrl
                url
              }
            }
          }
        }
      }
    }
    """
  end

  defp pagination_params(limit, "") do
    "first: #{limit}"
  end

  defp pagination_params(limit, after_cursor) do
    "first: #{limit}, after: \\\"#{after_cursor}\\\""
  end

  defp send_request(graphql_query, auth_token) do
    headers = [Authorization: "bearer #{auth_token}"]
    query = cleanup_query(graphql_query)

    case HTTPoison.post(@api_uri, ~s({"query": "#{query}"}), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body, keys: :atoms)

      _ ->
        %{}
    end
  end

  defp cleanup_query(query) do
    query |> String.replace(~r/\s+/, " ")
  end

  defp compile_organizations(%{data: %{viewer: %{organizations: orgas}}}) do
    %{edges: edges, pageInfo: info} = orgas
    %{hasNextPage: has_next_page, endCursor: end_cursor} = info
    page_info = %PageInfo{has_next_page: has_next_page, end_cursor: end_cursor}

    organizations =
      edges
      |> Enum.map(&build_organization(&1.node))
      |> Enum.reject(&is_nil/1)

    {page_info, organizations}
  end

  defp compile_organizations(_data), do: {%PageInfo{}, []}

  defp compile_repos(%{data: %{viewer: %{organization: %{repositories: repos}}}}) do
    %{edges: edges, pageInfo: page_info} = repos
    %{hasNextPage: has_next_page, endCursor: end_cursor} = page_info
    page_info = %PageInfo{has_next_page: has_next_page, end_cursor: end_cursor}

    repositories =
      edges
      |> Enum.map(&build_repository(&1.node))
      |> Enum.reject(&is_nil/1)

    {page_info, repositories}
  end

  defp compile_repos(_data), do: []

  defp compile_user_repos(%{data: %{viewer: %{repositories: repos}}}) do
    %{edges: edges, pageInfo: page_info} = repos
    %{hasNextPage: has_next_page, endCursor: end_cursor} = page_info
    page_info = %PageInfo{has_next_page: has_next_page, end_cursor: end_cursor}

    repositories =
      edges
      |> Enum.map(&build_repository(&1.node))
      |> Enum.reject(&is_nil/1)

    {page_info, repositories}
  end

  defp compile_user_repos(_data), do: []

  defp build_organization(%{viewerCanAdminister: true} = data) do
    %Organization{
      id: data.login,
      name: data.name,
      description: data.description,
      avatar_url: data.avatarUrl
    }
  end

  defp build_organization(_data), do: nil

  defp build_repository(%{id: id, name: name, descriptionHTML: description, url: url} = data) do
    %Repository{
      id: id,
      name: name,
      description: description,
      url: url,
      language: build_language(data),
      owner: build_owner(data)
    }
  end

  defp build_repository(_data), do: []

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
