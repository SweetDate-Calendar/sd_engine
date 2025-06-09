defmodule CLP.Repo do
  use Ecto.Repo,
    otp_app: :clp_engine,
    adapter: Ecto.Adapters.Postgres
end
