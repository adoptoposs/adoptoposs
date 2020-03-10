defmodule Adoptoposs.Network.Api.GithubInMemory do
  alias Adoptoposs.Network.Api

  import Adoptoposs.Factory

  @behaviour Api

  @impl Api
  def organizations(_token, _limit, _after_cursor) do
    {build(:page_info), build_list(2, :organization)}
  end

  @impl Api
  def repos(_token, _organization, _limit, _after_cursor) do
    {build(:page_info), build_list(2, :repository)}
  end

  @impl Api
  def user_repos(_token, _limit, _after_cursor) do
    {build(:page_info), build_list(2, :repository)}
  end
end
