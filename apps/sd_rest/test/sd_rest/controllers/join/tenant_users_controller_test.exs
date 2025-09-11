defmodule SDRest.Join.TenantUsersControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  @tenant_users_endpoint "/api/v1/join/tenant_users"

  describe "POST /join/tenant_users" do
    test "creates a tenant-user join", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      body = %{
        "tenant_id" => tenant.id,
        "user_id" => user.id,
        "role" => "admin"
      }

      conn = signed_post(conn, @tenant_users_endpoint, body)
      json = json_response(conn, 201)

      assert json["status"] == "ok"
      assert join = json["tenant_user"]
      assert join["tenant_id"] == tenant.id
      assert join["user_id"] == user.id
      assert join["role"] == "admin"
    end

    test "returns 422 validation failed on missing fields", %{conn: conn} do
      conn = signed_post(conn, @tenant_users_endpoint, %{})
      json = json_response(conn, 422)

      assert json == %{
               "details" => %{
                 "tenant_id" => ["can't be blank"],
                 "user_id" => ["can't be blank"]
               },
               "message" => "validation failed",
               "status" => "error"
             }
    end

    test "returns 422 on missing bad uuids", %{conn: conn} do
      conn = signed_post(conn, @tenant_users_endpoint, %{"user_id" => "bad-uuid"})
      json = json_response(conn, 422)

      assert json == %{
               "details" => %{
                 "tenant_id" => ["can't be blank"],
                 "user_id" => ["is not a valid UUID"]
               },
               "message" => "validation failed",
               "status" => "error"
             }
    end
  end

  describe "PATCH /join/tenant_users/:id" do
    test "updates a tenant-user role", %{conn: conn} do
      # create and preload user
      tenant_user = SD.TenantsFixtures.tenant_user_fixture()

      # perform signed PATCH
      conn =
        signed_patch(conn, "#{@tenant_users_endpoint}/#{tenant_user.tenant_id}", %{
          "role" => "owner",
          "user_id" => tenant_user.user_id
        })

      json = json_response(conn, 200)

      assert json["status"] == "ok"
      assert json["tenant_id"] == tenant_user.tenant_id
      assert json["user"]["id"] == tenant_user.user_id
      assert json["user"]["name"] == tenant_user.user.name
      assert json["user"]["email"] == tenant_user.user.email
    end

    test "returns 404 if tenant_user not found", %{conn: conn} do
      conn =
        signed_patch(conn, "#{@tenant_users_endpoint}/00000000-0000-0000-0000-000000000000", %{
          "role" => "admin"
        })

      json = json_response(conn, 404)
      assert json["status"] == "error"
      assert json["message"] == "invalid id"
    end
  end

  describe "DELETE /join/tenant_users/:id" do
    test "deletes a tenant_user", %{conn: conn} do
      tenant_user = SD.TenantsFixtures.tenant_user_fixture()

      conn =
        signed_delete(conn, "#{@tenant_users_endpoint}/#{tenant_user.tenant_id}", %{
          "user_id" => tenant_user.user_id,
          "tenant_id" => tenant_user.tenant_id
        })

      json = json_response(conn, 200)

      assert json["status"] == "ok"
      assert json["tenant_user"]["tenant_id"] == tenant_user.tenant_id
      assert json["tenant_user"]["user_id"] == tenant_user.user_id
      assert json["tenant_user"]["role"] == Atom.to_string(tenant_user.role)
    end

    test "returns 404 for nonexistent tenant", %{conn: conn} do
      conn = signed_delete(conn, "#{@tenant_users_endpoint}/00000000-0000-0000-0000-000000000000")
      json = json_response(conn, 404)
      assert json["status"] == "error"
      assert json["message"] == "invalid id"
    end
  end
end
