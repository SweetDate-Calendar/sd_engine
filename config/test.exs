import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sd_engine, SD.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "sd_engine_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2,
  port: 5433

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sd_engine_web, SDWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "BueOLdp058N5KQlyJvHYHcfpeQPRGIHdKgaqVgCqgafqGT/1Qzf85JwNA+XS8XsM",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# In test we don't send emails
config :sd_engine, SD.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :sd_engine, :tcp,
  port: String.to_integer(System.get_env("CLP_TCP_PORT") || "5050"),
  sweet_date_account_id:
    System.get_env("CLP_ACCESS_KEY_ID") || "99eccb44-2b95-489e-8445-99f47aa45262",
  sweet_access_api_key:
    System.get_env("CLP_SECRET_ACCESS_KEY") || "7Xp6HIex5rcxRBELL9ZVhYVb_ZPQE_3lbxKweXpVJow"
