defmodule SDRest.Join.TenantUsersControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  describe "POST /api/v1/join/tenants/TENANT_ID/users" do
    test "creates a tenan_user", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      endpoint =
        "/api/v1/join/tenants/#{tenant.id}/users/"

      body = %{
        "user_id" => user.id,
        "role" => "admin"
      }

      conn = signed_post(conn, endpoint, body)
      json = json_response(conn, 201)
      assert json["status"] == "ok"
      assert json["user"]["email"] == user.email
      assert json["user"]["name"] == user.name
      assert json["user"]["role"] == "admin"
    end

    test "returns 422 validation failure", %{conn: conn} do
      endpoint =
        "/api/v1/join/tenants/1234/users/"

      conn = signed_post(conn, endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"]["tenant_id"] == ["is not a valid UUID"]
      assert json["message"]["user_id"] == ["can't be blank"]
    end

    test "returns 422 on missing bad uuids", %{conn: conn} do
      endpoint = "/api/v1/join/tenants/bad-uuid/users"
      conn = signed_post(conn, endpoint, %{"user_id" => "bad-uuid"})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"]["tenant_id"] == ["is not a valid UUID"]
      assert json["message"]["user_id"] == ["is not a valid UUID"]
    end
  end

  describe "PATCH /api/v1/join/tenants/TENANT_ID/users/" do
    test "updates a tenant_user role", %{conn: conn} do
      tenant_user = SD.TenantsFixtures.tenant_user_fixture()

      payload = %{
        "role" => "owner"
      }

      endpoint = "/api/v1/join/tenants/#{tenant_user.tenant_id}/users/#{tenant_user.user_id}"

      conn =
        signed_patch(conn, endpoint, payload)

      json = json_response(conn, 200)

      assert json["status"] == "ok"
      assert json["user"]["role"] == "owner"
    end

    test "returns 404 if tenant_user not found", %{conn: conn} do
      endpoint =
        "/api/v1/join/tenants/00000000-0000-0000-0000-000000000000/users/00000000-0000-0000-0000-000000000000"

      conn =
        signed_patch(conn, endpoint, %{
          "role" => "admin"
        })

      json = json_response(conn, 404)

      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end

  describe "DELETE /join/tenant_users/:id" do
    test "deletes a tenant_user", %{conn: conn} do
      tenant_user = SD.TenantsFixtures.tenant_user_fixture()

      endpoint =
        "/api/v1/join/tenants/#{tenant_user.tenant_id}/users/#{tenant_user.user_id}"

      conn =
        signed_delete(conn, endpoint, %{})

      json = json_response(conn, 200)

      assert json["status"] == "ok"
    end

    test "returns 404 for nonexistent tenant", %{conn: conn} do
      endpoint =
        "/api/v1/join/tenants/00000000-0000-0000-0000-000000000000/users/00000000-0000-0000-0000-000000000000"

      conn = signed_delete(conn, endpoint)
      json = json_response(conn, 404)
      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end
end
