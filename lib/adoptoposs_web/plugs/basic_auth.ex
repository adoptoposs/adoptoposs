defmodule AdoptopossWeb.Plugs.BasicAuth do
  @moduledoc """
  Plug to require HTTP basic auth for certain pipelines or routes.
  """

  import Plug.BasicAuth

  def init(opts), do: opts

  @doc """
  Asks for basic auth credentials if `username:` and `password:`
  are configured in the `:adoptoposs, :basic_auth` config.
  """
  def call(%Plug.Conn{} = conn, _opts) do
    username = basic_auth_config(:username)
    password = basic_auth_config(:password)

    if username && password do
      basic_auth(conn, username: username, password: password)
    else
      conn
    end
  end

  defp basic_auth_config(field) do
    Application.get_env(:adoptoposs, :basic_auth)[field]
  end
end
