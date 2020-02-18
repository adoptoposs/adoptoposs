defmodule Adoptoposs.Network do
  alias Adoptoposs.Network.Github

  @doc """
  Fetch a user's organizations from the given provider.
  """
  def organizations(token, provider, limit, after_cursor \\ "")

  def organizations(token, "github", limit, after_cursor) do
    Github.organizations(token, limit, after_cursor)
  end

  def organizations(_token, provider, _limit, _after_cursor) do
    raise_provider_not_implemented(provider, "organizations/4")
  end

  @doc """
  Fetch an organization's public repositories from the given provider.
  """
  def repos(token, provider, organization, limit, after_cursor \\ "")

  def repos(token, "github", organization, limit, after_cursor) do
    Github.repos(token, organization, limit, after_cursor)
  end

  def repos(_token, provider, _organization, _limit, _after_cursor) do
    raise_provider_not_implemented(provider, "repos/4")
  end

  @doc """
  Fetch an user's public repositories from the given provider.
  """
  def user_repos(token, provider, limit, after_cursor \\ "")

  def user_repos(token, "github", limit, after_cursor) do
    Github.user_repos(token, limit, after_cursor)
  end

  def user_repos(_token, provider, _limit, _after_cursor) do
    raise_provider_not_implemented(provider, "user_repos/4")
  end

  defp raise_provider_not_implemented(provider, fn_name) do
    function = "#{__MODULE__}.#{fn_name}"
    raise "#{function} for provider \"#{provider}\" is not implemented."
  end
end
