defmodule Adoptoposs.Network.Api.GithubInMemory do
  alias Adoptoposs.Network.Api

  import Adoptoposs.Factory

  @behaviour Api

  @impl Api
  def organizations(_token, limit, _after_cursor) do
    {build(:page_info), build_list(limit, :organization)}
  end

  @impl Api
  def repos(_token, _organization, limit, _after_cursor) do
    {build(:page_info), build_repos(limit)}
  end

  @impl Api
  def user_repos(_token, limit, _after_cursor) do
    {build(:page_info), build_repos(limit)}
  end

  defp build_repos(count) do
    languages = ["Elixir", "JavaScript", "Ruby", "Rust", "Go", "Python"]

    Enum.map(1..count, fn _ ->
      language = build(:language, name: Enum.random(languages))
      build(:repository, language: language)
    end)
  end
end
