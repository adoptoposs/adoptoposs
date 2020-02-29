defmodule Adoptoposs.TestHelpers do
  @moduledoc """
  Helper functions for tests
  """

  @doc """
  Returns the absolute path of the fixture file with the given name

  ## Examples

        iex> fixture_path!("languages.yml")
        "/your/app/path/test/support/fixtures/languages.yml"

        iex> fixture_path!("not-available.file")
        ** (File.Error, could not find fixture file "not-available.file")
  """
  def fixture_path!(name) do
    path = Path.expand("./test/support/fixtures/#{name}")

    unless File.exists?(path) do
      raise File.Error, action: "find fixture file", path: path
    end

    path
  end
end
