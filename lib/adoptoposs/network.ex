defmodule Adoptoposs.Network do
  @doc """
  Fetch a user's organizations from the given provider.
  """
  def organizations(token, provider, limit, after_cursor \\ "")

  def organizations(token, provider, limit, after_cursor) do
    api(provider).organizations(token, limit, after_cursor)
  end

  @doc """
  Fetch an organization's public repositories from the given provider.
  """
  def repos(token, provider, organization, limit, after_cursor \\ "")

  def repos(token, provider, organization, limit, after_cursor) do
    api(provider).repos(token, organization, limit, after_cursor)
  end

  @doc """
  Fetch repositories with the given ids from the given provider.
  """
  def repos(token, provider, ids) do
    api(provider).repos(token, ids)
  end

  @doc """
  Fetch a user's public repositories from the given provider.
  """
  def user_repos(token, provider, limit, after_cursor \\ "")

  def user_repos(token, provider, limit, after_cursor) do
    api(provider).user_repos(token, limit, after_cursor)
  end

  defp api(name) do
    module = Application.get_env(:adoptoposs, :"#{name}_api")

    unless module do
      raise "Api module for provider \"#{name}\" is not configured."
    end

    module
  end
end
