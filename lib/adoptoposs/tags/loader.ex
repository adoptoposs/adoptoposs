defmodule Adoptoposs.Tags.Loader do
  @moduledoc """
  Provides functions to handle data loading for tags.
  """

  @type_filters ~w{programming markup}

  @doc """
  Fetches programming languages from an optional source file and
  compiles a list of `%Tag{}` attrs.

  The `source_file` is assumes to be a file path or uri to a YAML file
  whose entries have the following items:

  - a key, being the language name
  - a "color" value
  - a "type" value (only "programming" and "markup" types are considered)
  """
  def fetch_languages(source_file) do
    source_file
    |> parse_yaml()
    |> filter_languages()
  end

  defp parse_yaml("http" <> _ = source) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(source)
    YamlElixir.read_from_string!(body)
  end

  defp parse_yaml(source) do
    YamlElixir.read_from_file!(source)
  end

  defp filter_languages(%{} = data) do
    data |> Enum.reduce([], &build_language/2)
  end

  defp build_language({key, %{"type" => type, "color" => color}}, result)
       when type in @type_filters do
    result ++ [%{name: key, type: "language", color: color}]
  end

  defp build_language(_, result), do: result
end
