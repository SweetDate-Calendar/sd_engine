defmodule SD.Repo do
  use Ecto.Repo,
    otp_app: :sd_engine,
    adapter: Ecto.Adapters.Postgres
end
