defmodule Adoptoposs.Network do
  alias Adoptoposs.Network.Github

  def organizations(token, provider, limit, start_cursor \\ "")

  def organizations(token, "github", limit, start_cursor) do
    Github.organizations(token, limit, start_cursor)
  end

  def organizations(_token, provider, _limit, _start_cursor) do
    raise_provider_not_implemented(provider)
  end

  def repos(token, preovider, organization, limit, start_cursor \\ "")

  def repos(token, "github", organization, limit, start_cursor) do
    Github.repos(token, organization, limit, start_cursor)
  end

  def repos(_token, provider, _organization, _limit, _start_cursor) do
    raise_provider_not_implemented(provider)
  end

  def user_repos(token, provider, limit, start_cursor \\ "")

  def user_repos(token, "github", limit, start_cursor) do
    Github.user_repos(token, limit, start_cursor)
  end

  def user_repos(_token, provider, _limit, _start_cursor) do
    raise_provider_not_implemented(provider)
  end

  defp raise_provider_not_implemented(provider) do
    raise "#{__MODULE__}.search_repos/4 for provider \"#{provider}\" is not implemented."
  end
end
