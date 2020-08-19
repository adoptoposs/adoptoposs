defprotocol Adoptoposs.Network.Api do
  alias Adoptoposs.Network.{Repository, Organization, PageInfo}

  @doc """
  Get the provider for the Api.
  """
  @callback provider() :: String.t()

  @doc """
  Get the current user’s paginated administerable organizations.
  It takes the auth token, the limit and a start cursor for pagination.
  It returns a result tuple containing the `PageInfo` and a list of `Organization`s.
  """
  @callback organizations(String.t(), integer(), String.t()) ::
              {atom(), {PageInfo.t(), list(Organization.t())}}

  @doc """
  Get repos for given ids.
  It returns a result tuple containing a list of `Repository`s.
  """
  @callback repos(String.t(), list(String.t())) :: {atom(), list(Repository.t())}

  @doc """
  Get paginated repos for a given organisation.
  It returns a result tuple containing the `PageInfo` and a list of `Repository`s.
  """
  @callback repos(String.t(), String.t(), integer(), String.t()) ::
              {atom(), {PageInfo.t(), list(Repository.t())}}

  @doc """
  Get paginated repos for a given user.
  It returns a result tuple containing the `PageInfo` and a list of `Repository`s.
  """
  @callback user_repos(String.t(), integer(), String.t()) ::
              {atom(), {PageInfo.t(), list(Repository.t())}}
end
