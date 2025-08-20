defmodule SD_REST.Router do
  use Plug.Router
  alias SD_REST.Plugs.SignatureV1

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json, :urlencoded],
    pass: ["*/*"],
    json_decoder: Jason
  )

  alias SD_REST.Plugs.SignatureV1
  alias SD_REST.Auth.Resolver
  plug(SignatureV1, resolver: &Resolver.pubkey/1)

  plug(:dispatch)

  get "/health" do
    send_json(conn, 200, %{status: "ok"})
  end

  # Protected example
  get "/whoami" do
    send_json(conn, 200, %{status: "ok", app_id: conn.assigns[:sd_app_id]})
  end

  get("/api/v1/tenants", do: SD_REST.TenantsController.index(conn))

  match _ do
    send_json(conn, 404, %{error: "not_found"})
  end

  defp send_json(conn, status, map) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Jason.encode!(map))
  end
end
