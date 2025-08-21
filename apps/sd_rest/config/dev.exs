# apps/sd_rest/config/dev.exs
import Config

config :sd_rest, SDRest.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("SD_REST_PORT") || "4008")],
  adapter: Bandit.PhoenixAdapter,
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "5ul4gOmZlMxDhsmVGpSRC2p0qH6FdieFTFdfmgdxVG7KzknVxfqxpnscqkpt8LIA",
  render_errors: [formats: [json: SDRest.ErrorJSON], layout: false]
