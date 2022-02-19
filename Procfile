web: MIX_ENV=prod mix compile --force && mix phx.server
release: MIX_ENV=prod mix ecto.migrate && ./bin/postdeploy
