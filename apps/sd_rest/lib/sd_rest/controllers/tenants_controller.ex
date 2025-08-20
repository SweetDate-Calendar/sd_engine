defmodule SD_REST.TenantsController do
  import Plug.Conn
  # adjust to your context namespace (e.g., SD.Tenants)
  alias SD

  @default_limit 25
  @max_limit 100

  # GET /api/v1/tenants?limit=25&offset=0
  def index(%Plug.Conn{} = conn) do
    params = conn.params || %{}
    {limit, offset} = pagination(params)

    # Replace with your actual context calls:
    # {items, count} = SD.Tenants.list_tenants(limit: limit, offset: offset)
    items = SD.Tenants.list_tenants(limit: limit, offset: offset)

    json(conn, 200, %{
      items: Enum.map(items, &tenant_json/1),
      limit: limit,
      offset: offset
    })
  end

  defp tenant_json(t) do
    %{
      id: t.id,
      name: t.name,
      inserted_at: t.inserted_at,
      updated_at: t.updated_at
    }
  end

  defp pagination(params) do
    limit =
      params["limit"]
      |> to_int(@default_limit)
      |> min(@max_limit)
      |> max(1)

    offset =
      params["offset"]
      |> to_int(0)
      |> max(0)

    {limit, offset}
  end

  defp to_int(nil, default), do: default
  defp to_int(v, _default) when is_integer(v), do: v

  defp to_int(v, default) when is_binary(v) do
    case Integer.parse(v) do
      {i, ""} -> i
      _ -> default
    end
  end

  defp json(conn, status, map) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(map))
  end
end
