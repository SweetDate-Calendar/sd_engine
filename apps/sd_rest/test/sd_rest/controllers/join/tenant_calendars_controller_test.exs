defmodule SDRest.Join.TenantCalendarsControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  describe "POST /api/v1/join/tenants/:tenant_id/calendars" do
    test "creates a tenant_calendar", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture(%{name: "TenantJoin #{System.unique_integer()}"})

      calendar =
        SD.CalendarsFixtures.calendar_fixture(%{name: "Calendar #{System.unique_integer()}"})

      payload = %{
        "calendar_id" => calendar.id,
        "visibility" => "shared"
      }

      endpoint = "/api/v1/join/tenants/#{tenant.id}/calendars"
      conn = signed_post(conn, endpoint, payload)

      assert json = json_response(conn, 201)

      assert json["status"] == "ok"
      calendar_json = json["calendar"]
      assert calendar_json["name"] == calendar.name
      assert calendar_json["visibility"] == "public"
      assert calendar_json["id"] == calendar.id
    end

    test "returns 422 on missing fields", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture(%{name: "TenantJoin #{System.unique_integer()}"})
      endpoint = "/api/v1/join/tenants/#{tenant.id}/calendars"
      conn = signed_post(conn, endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"]["calendar_id"] == ["can't be blank"]
    end

    test "returns 422 with invalid tenant_id UUID and missing calendar_id", %{conn: conn} do
      endpoint =
        "/api/v1/join/tenants/123/calendars/"

      conn = signed_post(conn, endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"]["calendar_id"] == ["can't be blank"]
      assert json["message"]["tenant_id"] == ["is not a valid UUID"]
    end

    test "returns 422 on invalid UUIDs", %{conn: conn} do
      endpoint =
        "/api/v1/join/tenants/bad-uuid/calendars/"

      conn =
        signed_post(conn, endpoint, %{
          "calendar_id" => "also-bad"
        })

      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"]["calendar_id"] == ["is not a valid UUID"]
      assert json["message"]["tenant_id"] == ["is not a valid UUID"]
    end
  end

  describe "DELETE /api/v1/join/tenants/:tenants_id/calendars/:id" do
    test "deletes an existing tenant_calendar", %{conn: conn} do
      tenant_calendar = SD.CalendarsFixtures.tenant_calendar_fixture()

      path =
        "/api/v1/join/tenants/#{tenant_calendar.tenant_id}/calendars/#{tenant_calendar.calendar_id}"

      conn = signed_delete(conn, path)

      json = json_response(conn, 200)
      assert json["status"] == "ok"
    end

    test "returns 404 for nonexistent calendar", %{conn: conn} do
      path = "/api/v1/join/tenants/#{Ecto.UUID.generate()}/calendars/#{Ecto.UUID.generate()}"
      conn = signed_delete(conn, path)

      json = json_response(conn, 404)
      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end
end
