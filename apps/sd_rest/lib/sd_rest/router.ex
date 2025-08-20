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
  # post "/api/v1/tenants"        , do: SD_REST.TenantsController.create(conn)
  # get  "/api/v1/tenants/:id"    , do: SD_REST.TenantsController.show(conn, id)
  # put  "/api/v1/tenants/:id"    , do: SD_REST.TenantsController.update(conn, id)
  # delete "/api/v1/tenants/:id"  , do: SD_REST.TenantsController.delete(conn, id)

  # # Calendars (optionally nested under tenant)
  # get  "/api/v1/calendars"           , do: SD_REST.CalendarsController.index(conn)
  # post "/api/v1/calendars"           , do: SD_REST.CalendarsController.create(conn)
  # get  "/api/v1/calendars/:id"       , do: SD_REST.CalendarsController.show(conn, id)
  # put  "/api/v1/calendars/:id"       , do: SD_REST.CalendarsController.update(conn, id)
  # delete "/api/v1/calendars/:id"     , do: SD_REST.CalendarsController.delete(conn, id)

  # # Events
  # get  "/api/v1/events"              , do: SD_REST.EventsController.index(conn)
  # post "/api/v1/events"              , do: SD_REST.EventsController.create(conn)
  # get  "/api/v1/events/:id"          , do: SD_REST.EventsController.show(conn, id)
  # put  "/api/v1/events/:id"          , do: SD_REST.EventsController.update(conn, id)
  # delete "/api/v1/events/:id"        , do: SD_REST.EventsController.delete(conn, id)

  match _ do
    send_json(conn, 404, %{error: "not_found"})
  end

  defp send_json(conn, status, map) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Jason.encode!(map))
  end
end
