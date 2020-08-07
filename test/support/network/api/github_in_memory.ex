defmodule Adoptoposs.Network.Api.GithubInMemory do
  alias Adoptoposs.Network.Api

  import Adoptoposs.Factory

  @behaviour Api

  @impl Api
  def provider, do: Api.Github.provider()

  @impl Api
  def organizations(_token, limit, _after_cursor) do
    {:ok, {build(:page_info), build_list(limit, :organization)}}
  end

  @impl Api
  def repos(_token, ids) do
    {:ok, ids |> Enum.map(&build(:repository, id: to_string(&1)))}
  end

  @impl Api
  def repos(_token, organization, limit, _after_cursor) do
    {:ok, {build(:page_info), build_repos(organization, limit)}}
  end

  @impl Api
  def user_repos(_token, limit, _after_cursor) do
    {:ok, {build(:page_info), build_repos("user", limit)}}
  end

  defp build_repos(organization, count) do
    languages = ["Elixir", "JavaScript", "Ruby", "Rust", "Go", "Python"]

    Enum.map(1..count, fn id ->
      name = Enum.at(languages, rem(10, Enum.count(languages)))
      language = build(:language, name: name)

      build(:repository, id: to_string(id), name: "#{organization}-repo-#{id}", language: language)
    end)
  end
end
