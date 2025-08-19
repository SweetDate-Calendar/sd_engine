defmodule SD_REST.Router do
  use Plug.Router

  plug :match

  plug Plug.Parsers,
    parsers: [:json, :urlencoded],
    pass: ["*/*"],
    json_decoder: Jason

  plug :dispatch

  # Public health check (will be mounted at /api/health)
  get "/health" do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, ~s({"status":"ok"}))
  end

  # Catch-all for unknown API routes
  match _ do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(404, ~s({"error":"not_found"}))
  end
end
