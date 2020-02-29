alias Adoptoposs.Tags

try do
  "https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml"
  |> Tags.Loader.fetch_languages()
  |> Tags.upsert_tags()
rescue
  error in [HTTPoison.Error, File.Error] ->
    IO.inspect(error)
    IO.puts("Fetching languages failed. Please run `mix fetch.languages` manually.")
end

