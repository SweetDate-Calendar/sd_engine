defmodule SDRest.TenantsControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  import Phoenix.ConnTest
  import SD.TenantsFixtures

  @base "/api/v1/tenants"

  setup %{conn: conn} do
    tenant_fixture(%{name: "Alpha"})
    tenant_fixture(%{name: "Beta"})
    tenant_fixture(%{name: "Charlie"})

    {:ok, conn: conn}
  end

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
