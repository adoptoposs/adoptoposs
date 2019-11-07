defmodule Adoptoposs.Repo do
  use Ecto.Repo,
    otp_app: :adoptoposs,
    adapter: Ecto.Adapters.Postgres
end
