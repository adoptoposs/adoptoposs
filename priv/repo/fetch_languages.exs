alias Adoptoposs.Tags
alias Adoptoposs.Tags.Tag

try do
  "https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml"
  |> Tags.Loader.fetch_languages()
  |> List.insert_at(0, Tag.Utility.unknown())
  |> Enum.map(&Map.from_struct/1)
  |> Tags.upsert_tags()
rescue
  error in [HTTPoison.Error, File.Error] ->
    IO.inspect(error)
    IO.puts("Fetching languages failed. Please run `mix fetch.languages` manually.")
end

