defmodule SDRest.Endpoint do
  use Phoenix.Endpoint, otp_app: :sd_rest

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # Drop Plug.Session unless you need signed cookies
  # plug Plug.Session, @session_options

  plug SDRest.Router
end
