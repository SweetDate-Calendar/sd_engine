defmodule SDRest.Join.TenantUsersControllerTest do
  use SDRest.ConnCase, async: true

  alias SD.Tenants
  alias SD.Accounts

  @join_endpoint "/api/v1/join/users"

  describe "POST /join/users" do
    test "creates a tenant-user join", %{conn: conn} do
      IO.inspect("============================")
      tenant = SD.TenantsFixtures.tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      body = %{
        "tenant_id" => tenant.id,
        "user_id" => user.id,
        "role" => "admin"
      }

      conn = signed_post(conn, @join_endpoint, body)

      json = json_response(conn, 201)
      assert json["status"] == "ok"
      assert join = json["tenant_user"]
      assert join["tenant_id"] == tenant.id
      assert join["user_id"] == user.id
      assert join["role"] == "admin"
      assert(false)
    end

    test "returns 422 on missing fields", %{conn: conn} do
      conn = signed_post(conn, @join_endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert Map.has_key?(json["details"], "tenant_id")
      assert Map.has_key?(json["details"], "user_id")
    end
  end

  describe "PATCH /join/users/:id" do
    test "updates a tenant-user role", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      {:ok, join} =
        Tenants.create_tenant_user(%{
          "tenant_id" => tenant.id,
          "user_id" => user.id,
          "role" => "guest"
        })

      conn =
        signed_patch(conn, "#{@join_endpoint}/#{join.id}", %{
          "role" => "owner"
        })

      json = json_response(conn, 200)
      assert json["status"] == "ok"
      assert json["tenant_user"]["role"] == "owner"
    end

    test "returns 404 if join not found", %{conn: conn} do
      conn =
        signed_patch(conn, "#{@join_endpoint}/00000000-0000-0000-0000-000000000000", %{
          "role" => "admin"
        })

      json = json_response(conn, 404)
      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end

  describe "DELETE /join/users/:id" do
    test "deletes a tenant-user join", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      {:ok, join} =
        Tenants.create_tenant_user(%{
          "tenant_id" => tenant.id,
          "user_id" => user.id,
          "role" => "admin"
        })

      conn = signed_delete(conn, "#{@join_endpoint}/#{join.id}")
      json = json_response(conn, 200)

      assert json["status"] == "ok"
      assert json["tenant_user"]["id"] == join.id
    end

    test "returns 404 for nonexistent join", %{conn: conn} do
      conn = signed_delete(conn, "#{@join_endpoint}/00000000-0000-0000-0000-000000000000")
      json = json_response(conn, 404)

      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end
end
