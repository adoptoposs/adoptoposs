defprotocol Adoptoposs.Network.Api do
  alias Adoptoposs.Network.{Repository, Organization, PageInfo}

  @doc """
  Get the current user’s paginated administerable organizations.
  It takes the auth token, the limit and a start cursor for pagination.
  It returns a result tuple containing the `PageInfo` and a list of `Organization`s.
  """
  @spec organizations(String.t(), integer(), String.t()) ::
          {atom(), {PageInfo.t(), list(Organization.t())}}
  def organizations(token, limit, after_cursor)

  @doc """
  Get repos for given ids.
  It returns a result tuple containing a list of `Repository`s.
  """
  @spec repos(String.t(), list(String.t())) :: {atom(), list(Repository.t())}
  def repos(token, ids)

  @doc """
  Get paginated repos for a given organisation.
  It returns a result tuple containing the `PageInfo` and a list of `Repository`s.
  """
  @spec repos(String.t(), String.t(), integer(), String.t()) ::
          {atom(), {PageInfo.t(), list(Repository.t())}}
  def repos(token, organization, limit, after_cursor)

  @doc """
  Get paginated repos for a given user.
  It returns a result tuple containing the `PageInfo` and a list of `Repository`s.
  """
  @spec user_repos(String.t(), integer(), String.t()) ::
          {atom(), {PageInfo.t(), list(Repository.t())}}
  def user_repos(token, limit, after_cursor)
end
