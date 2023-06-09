defmodule Adoptoposs.UriHelper do
  @doc """
  Attaches the given params to the given path.

  ## Examples

    iex> Adoptoposs.UriHelper.extend_path("https://example.com", q: "test")
    "https://example.com?q=test"

    iex> Adoptoposs.UriHelper.extend_path("https://example.com?q=test", other: "test2")
    "https://example.com?other=test2&q=test"

    iex> Adoptoposs.UriHelper.extend_path("https://example.com", %{q: "test"})
    "https://example.com?q=test"

    iex> Adoptoposs.UriHelper.extend_path("https://example.com?q=test", q: "test")
    "https://example.com?q=test"

    iex> Adoptoposs.UriHelper.extend_path("https://example.com", %{})
    "https://example.com?"

  """
  def extend_path(path, params) when is_binary(path) do
    uri = URI.parse(path)

    query =
      (uri.query || "")
      |> URI.query_decoder()
      |> Map.new()
      |> Map.merge(Map.new(params, fn {x, y} -> {Atom.to_string(x), y} end))
      |> URI.encode_query()

    uri
    |> Map.put(:query, query)
    |> URI.to_string()
  end

  def extend_path(path, _params), do: path
end
