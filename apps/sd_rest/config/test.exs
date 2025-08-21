# apps/sd_rest/config/test.exs
import Config

config :sd_rest, SDRest.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4008],
  adapter: Bandit.PhoenixAdapter,
  server: true,
  secret_key_base: "test_secret_key_base_keep_this_long_enough",
  render_errors: [formats: [json: SDRest.ErrorJSON], layout: false],
  check_origin: false,
  code_reloader: false,
  debug_errors: false

config :logger, level: :warning
