defmodule SD_REST.TenantsControllerTest do
  use ExUnit.Case, async: true
  # or your Repo sandbox module
  use SD.DataCase

  import Plug.Test
  import Plug.Conn

  alias SD.Tenants
  alias SD_REST.TenantsController

  # Helpers ---------------------------------------------------------------

  defp json_decode!(%Plug.Conn{resp_body: body}), do: Jason.decode!(body)

  defp mk(conn_method, path, params \\ %{}) do
    # Plug.Parsers would normally populate conn.params; in unit tests we can set it ourselves
    conn(conn_method, path, params)
    |> Map.put(:params, params)
    |> put_req_header("content-type", "application/json")
  end

  defp tenant!(name), do: {:ok, t} = Tenants.create_tenant(%{name: name})

  # Seed a few tenants with deterministic names for ordering assertions
  setup do
    # Ensure empty table / isolated transaction is provided by SD.DataCase
    a = tenant!("Alpha")
    c = tenant!("Charlie")
    b = tenant!("Beta")
    {:ok, %{alpha: a, beta: b, charlie: c}}
  end

  # Tests ---------------------------------------------------------------

  test "GET /api/v1/tenants returns JSON with items, default pagination" do
    conn = mk(:get, "/api/v1/tenants")
    conn = TenantsController.index(conn)

    assert conn.status == 200

    %{"items" => items, "limit" => limit, "offset" => offset} = json_decode!(conn)

    assert is_list(items)
    assert limit == 25
    assert offset == 0

    # Default ordering should be by name asc: Alpha, Beta, Charlie
    assert Enum.map(items, & &1["name"]) == ["Alpha", "Beta", "Charlie"]
  end

  test "respects limit and offset params (ordered by name asc)" do
    # limit 2 → first two alphabetically
    conn1 =
      mk(:get, "/api/v1/tenants", %{"limit" => "2", "offset" => "0"}) |> TenantsController.index()

    %{"items" => items1, "limit" => 2, "offset" => 0} = json_decode!(conn1)
    assert Enum.map(items1, & &1["name"]) == ["Alpha", "Beta"]

    # offset 2 → starts from the 3rd alphabetically
    conn2 =
      mk(:get, "/api/v1/tenants", %{"limit" => "5", "offset" => "2"}) |> TenantsController.index()

    %{"items" => items2, "limit" => 5, "offset" => 2} = json_decode!(conn2)
    assert Enum.map(items2, & &1["name"]) == ["Charlie"]
  end

  test "invalid/negative params fall back to sane defaults" do
    # Non-integer limit → default 25 (controller echoes parsed limit/offset)
    conn1 =
      mk(:get, "/api/v1/tenants", %{"limit" => "NaN", "offset" => "-10"})
      |> TenantsController.index()

    %{"items" => items1, "limit" => 25, "offset" => 0} = json_decode!(conn1)
    # Items are all tenants in alphabetical order
    assert Enum.map(items1, & &1["name"]) == ["Alpha", "Beta", "Charlie"]

    # Overly large limit is capped by @max_limit (100) — here just assert it echoes 100
    conn2 =
      mk(:get, "/api/v1/tenants", %{"limit" => "9999", "offset" => "0"})
      |> TenantsController.index()

    %{"limit" => 100, "offset" => 0} = json_decode!(conn2)
  end
end
