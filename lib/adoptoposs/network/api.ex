defprotocol Adoptoposs.Network.Api do
  alias Adoptoposs.Network.{Repository, Organization, PageInfo}

  @doc """
  Get the current user’s administerable organizations.
  It takes the auth token, the limit and a start cursor for pagination.
  It returns a result tuple containing the `PageInfo` and a list of `Organization`s.
  """
  @callback organizations(String.t(), integer(), String.t()) ::
              {PageInfo.t(), list(Organization.t())}

  @doc """
  Get repos for a given organisation.
  It returns a result tuple containing the `PageInfo` and a list of `Repository`s.
  """
  @callback repos(String.t(), String.t(), integer(), String.t()) :: list(Repository.t())
end
