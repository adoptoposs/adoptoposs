[
  import_deps: [:ecto, :phoenix],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib,test}/**/*.{heex,ex,exs,exs.sample}",
    "priv/*/seeds.exs"
  ],
  subdirectories: ["priv/*/migrations"]
]
