defmodule Adoptoposs.Network.Api.Github do
  alias Adoptoposs.Network.{Api, Repository, PageInfo, Organization}
  alias Adoptoposs.Network.Repository.{User, Language}

  @behaviour Api

  @provider "github"
  @api_uri "https://api.github.com/graphql"

  @impl Api
  def provider, do: @provider

  @impl Api
  def organizations(token, limit, after_cursor) do
    organizations_query(limit, after_cursor)
    |> compile_data(token, &compile_organizations/1)
  end

  @impl Api
  def repos(token, ids) do
    repos_query(ids)
    |> compile_data(token, &compile_repos/1)
  end

  @impl Api
  def repos(token, organization, limit, after_cursor) do
    repos_query(organization, limit, after_cursor)
    |> compile_data(token, &compile_repos/1)
  end

  @impl Api
  def user_repos(token, limit, after_cursor) do
    user_repos_query(limit, after_cursor)
    |> compile_data(token, &compile_user_repos/1)
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
                description
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

  defp repos_query(ids) do
    params = ids_params(ids)

    ~s"""
    {
      nodes(#{params}) {
        ... on Repository {
          id
          name
          viewerCanAdminister
          description
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
              description
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

  defp ids_params(ids) do
    ids_list = ids |> Enum.map(&"\\\"#{&1}\\\"") |> Enum.join(", ")
    "ids: [#{ids_list}]"
  end

  defp compile_data(query, token, compile) do
    case send_request(query, token) do
      {:ok, data} ->
        {:ok, compile.(data)}

      error ->
        error
    end
  end

  defp send_request(graphql_query, auth_token) do
    headers = [Authorization: "bearer #{auth_token}"]
    query = cleanup_query(graphql_query)

    case HTTPoison.post(@api_uri, ~s({"query": "#{query}"}), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body, keys: :atoms)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        data = Jason.decode!(body, keys: :atoms)
        {:error, put_in(data, [:status_code], status_code)}
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

  defp compile_repos(%{data: %{nodes: repos}}) do
    repos
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&build_repository/1)
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

  defp build_repository(%{id: id, name: name, description: description, url: url} = data) do
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

  defp build_language(%{primaryLanguage: language}) when not is_nil(language) do
    struct(Language, language)
  end

  defp build_language(_data), do: %Language{}
end
