defmodule Adoptoposs.Network do
  alias Adoptoposs.Network.Github

  def search_repos(token, "github", query, limit) do
    Github.search_repos(token, query, limit)
  end

  def search_repos(_token, provider, _query, _limit) do
    raise "#{__MODULE__}.search_repos/4 for provider \"#{provider}\" is not implemented."
  end
end
