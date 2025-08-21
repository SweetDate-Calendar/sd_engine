defmodule SDRest.TenantsControllerTest do
  use SDRest.ConnCase, async: true

  import Phoenix.ConnTest
  import SD.TenantsFixtures
  import SD.AccountFixtures

  @base "/api/v1/tenants"

  # Fixed test keypair (base64url, no padding)
  @app_id "app_test_fixed"
  @public_key "Clq6ZOkhPxrTZeDkfhayAQbUS9dHU65JGw1f0UlaOuA"
  @private_key "hYdg0McePak4jrRyyWFtj0pLlprc4WwDhWhGLxcrqak"

  setup %{conn: conn} do
    # Insert an active credential with the fixed app_id and public key.
    _cred =
      credential_fixture(%{
        app_id: @app_id,
        public_key: @public_key,
        alg: :ed25519,
        status: :active
      })

    # Basic seed data used by index tests
    _ = tenant_fixture(%{name: "Alpha"})
    _ = tenant_fixture(%{name: "Beta"})
    _ = tenant_fixture(%{name: "Charlie"})

    {:ok, conn: conn}
  end

  ## ----------------- Auth helpers -----------------

  defp decode_priv!(b64url) do
    case Base.url_decode64(b64url, padding: false) do
      {:ok, bin} -> bin
      :error -> raise "invalid base64url private key"
    end
  end

  # Build headers the same way the plug verifies:
  # canonical = "v1\nMETHOD\n/path?qs\nTIMESTAMP\n-"
  defp sign_headers(method, full_path, app_id, priv_bin, ts \\ System.os_time(:second)) do
    method_up = method |> to_string() |> String.upcase()

    {path, qs} =
      case String.split(full_path, "?", parts: 2) do
        [p] -> {p, ""}
        [p, q] -> {p, q}
      end

    path_q = if qs == "", do: path, else: path <> "?" <> qs
    msg = Enum.join(["v1", method_up, path_q, Integer.to_string(ts), "-"], "\n")

    sig =
      :crypto.sign(:eddsa, :none, msg, [priv_bin, :ed25519])
      |> Base.url_encode64(padding: false)

    [
      {"sd-app-id", app_id},
      {"sd-timestamp", Integer.to_string(ts)},
      {"sd-signature", sig}
    ]
  end

  defp put_headers(conn, headers) do
    Enum.reduce(headers, conn, fn {k, v}, c -> put_req_header(c, k, v) end)
  end

  defp signed_get(conn, path) do
    priv = decode_priv!(@private_key)
    headers = sign_headers(:get, path, @app_id, priv)
    conn |> put_headers(headers) |> get(path)
  end

  defp signed_delete(conn, path) do
    priv = decode_priv!(@private_key)
    headers = sign_headers(:delete, path, @app_id, priv)
    conn |> put_headers(headers) |> delete(path)
  end

  defp signed_post(conn, path, params) do
    priv = decode_priv!(@private_key)
    headers = [{"content-type", "application/json"} | sign_headers(:post, path, @app_id, priv)]

    conn
    |> put_headers(headers)
    |> post(path, Jason.encode!(params))
  end

  defp signed_put(conn, path, params) do
    priv = decode_priv!(@private_key)
    headers = [{"content-type", "application/json"} | sign_headers(:put, path, @app_id, priv)]

    conn
    |> put_headers(headers)
    |> put(path, Jason.encode!(params))
  end

  ## ----------------- Tests -----------------

  describe "index" do
    test "GET /api/v1/tenants returns JSON with tenants, default pagination", %{conn: conn} do
      conn = signed_get(conn, @base)

      %{
        "status" => "ok",
        "result" => %{
          "tenants" => tenants,
          "limit" => 25,
          "offset" => 0
        }
      } = json_response(conn, 200)

      assert Enum.map(tenants, & &1["name"]) == ["Alpha", "Beta", "Charlie"]
    end

    test "respects limit & offset, ordered by name asc", %{conn: conn} do
      conn = signed_get(conn, "#{@base}?limit=2&offset=1")

      %{
        "status" => "ok",
        "result" => %{
          "tenants" => tenants,
          "limit" => 2,
          "offset" => 1
        }
      } = json_response(conn, 200)

      assert Enum.map(tenants, & &1["name"]) == ["Beta", "Charlie"]
    end
  end

  describe "show" do
    test "GET /api/v1/tenants/:id returns the tenant", %{conn: conn} do
      t = tenant_fixture(%{name: "Echo"})
      conn = signed_get(conn, "#{@base}/#{t.id}")

      %{
        "status" => "ok",
        "result" => %{"tenant" => jt}
      } = json_response(conn, 200)

      assert jt["id"] == t.id
      assert jt["name"] == "Echo"
      assert is_binary(jt["created_at"])
      assert is_binary(jt["updated_at"])
    end

    test "GET /api/v1/tenants/:id returns 404 when not found", %{conn: conn} do
      conn = signed_get(conn, "#{@base}/00000000-0000-0000-0000-000000000000")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn, 404)
    end
  end

  describe "create" do
    test "POST /api/v1/tenants creates and returns tenant", %{conn: conn} do
      conn = signed_post(conn, @base, %{"name" => "Delta"})

      %{
        "status" => "ok",
        "tenant" => jt
      } = json_response(conn, 201)

      assert jt["name"] == "Delta"
      assert jt["id"]
      assert jt["created_at"]
      assert jt["updated_at"]
    end

    test "POST /api/v1/tenants with invalid params returns 422", %{conn: conn} do
      conn = signed_post(conn, @base, %{"name" => ""})

      %{
        "status" => "error",
        "message" => "validation failed",
        "details" => _details
      } = json_response(conn, 422)
    end
  end

  describe "update" do
    test "PUT /api/v1/tenants/:id updates and returns tenant", %{conn: conn} do
      t = tenant_fixture(%{name: "Foxtrot"})
      conn = signed_put(conn, "#{@base}/#{t.id}", %{"name" => "Foxtrot Updated"})

      %{
        "status" => "ok",
        "tenant" => jt
      } = json_response(conn, 200)

      assert jt["id"] == t.id
      assert jt["name"] == "Foxtrot Updated"
    end

    test "PUT /api/v1/tenants/:id returns 404 for missing tenant", %{conn: conn} do
      conn = signed_put(conn, "#{@base}/00000000-0000-0000-0000-000000000000", %{"name" => "X"})
      assert %{"status" => "error", "message" => "not found"} = json_response(conn, 404)
    end

    test "PUT /api/v1/tenants/:id returns 422 for invalid input", %{conn: conn} do
      t = tenant_fixture(%{name: "Foxtrot"})
      conn = signed_put(conn, "#{@base}/#{t.id}", %{"name" => ""})

      %{
        "status" => "error",
        "message" => "not found or invalid input",
        "details" => _details
      } = json_response(conn, 422)
    end
  end

  describe "delete" do
    test "DELETE /api/v1/tenants/:id deletes and returns minimal payload", %{conn: conn} do
      t = tenant_fixture(%{name: "Golf"})
      conn = signed_delete(conn, "#{@base}/#{t.id}")

      %{
        "status" => "ok",
        "tenant" => %{"id" => id, "name" => name}
      } = json_response(conn, 200)

      assert id == t.id
      assert name == "Golf"

      # Now it should be gone
      conn2 = signed_get(build_conn(), "#{@base}/#{t.id}")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn2, 404)
    end

    test "DELETE /api/v1/tenants/:id returns 404 when not found", %{conn: conn} do
      conn = signed_delete(conn, "#{@base}/00000000-0000-0000-0000-000000000000")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn, 404)
    end
  end
end
