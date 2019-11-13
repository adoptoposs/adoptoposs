defprotocol Adoptoposs.Network.Api do
  alias Adoptoposs.Network.Repository

  @doc """
  Search repositories by the given query.
  It returns a result list of size `limit`.
  """
  @callback search_repos(String.t(), String.t(), integer()) :: list(Repository.t())
end
