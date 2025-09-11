defmodule SDRest.Join.TenantCalendarsControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  @tenant_calendar_endpoint "/api/v1/join/tenant_calendars"

  describe "POST /join/tenant_calendars" do
    test "creates a tenant-calendar join", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture(%{name: "TenantJoin #{System.unique_integer()}"})

      calendar =
        SD.CalendarsFixtures.calendar_fixture(%{name: "CalendarJoin #{System.unique_integer()}"})

      body = %{
        "tenant_id" => tenant.id,
        "calendar_id" => calendar.id
      }

      conn = signed_post(conn, @tenant_calendar_endpoint, body)

      assert json = json_response(conn, 201)
      assert json["status"] == "ok"
      assert tenant_calendar = json["tenant_calendar"]
      assert tenant_calendar["tenant_id"] == tenant.id
      assert tenant_calendar["calendar_id"] == calendar.id
    end

    test "returns 422 on missing fields", %{conn: conn} do
      conn = signed_post(conn, @tenant_calendar_endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert Map.has_key?(json["details"], "tenant_id")
      assert Map.has_key?(json["details"], "calendar_id")
    end
  end

  describe "DELETE /tenants/:tenant_id/calendars/:id" do
    test "deletes an existing tenant_calendar", %{conn: conn} do
      tenant_calendar = SD.CalendarsFixtures.tenant_calendar_fixture()

      path =
        "/api/v1/tenants/#{tenant_calendar.tenant_id}/calendars/#{tenant_calendar.calendar_id}"

      conn = signed_delete(conn, path)

      json = json_response(conn, 200)
      assert json["status"] == "ok"
    end

    test "returns 404 for nonexistent tenant_calendar", %{conn: conn} do
      path = "/api/v1/tenants/#{Ecto.UUID.generate()}/calendars/#{Ecto.UUID.generate()}"
      conn = signed_delete(conn, path)

      json = json_response(conn, 404)
      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end

  describe "POST /join/tenant_calendars — validation" do
    test "returns 422 on missing both tenant_id and calendar_id", %{conn: conn} do
      conn = signed_post(conn, @tenant_calendar_endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert json["details"]["tenant_id"] == ["can't be blank"]
      assert json["details"]["calendar_id"] == ["can't be blank"]
    end

    test "returns 422 on missing calendar_id", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture()

      conn =
        signed_post(conn, @tenant_calendar_endpoint, %{
          "tenant_id" => tenant.id
        })

      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert json["details"]["calendar_id"] == ["can't be blank"]
    end

    test "returns 422 on missing tenant_id", %{conn: conn} do
      calendar = SD.CalendarsFixtures.calendar_fixture()

      conn =
        signed_post(conn, @tenant_calendar_endpoint, %{
          "calendar_id" => calendar.id
        })

      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert json["details"]["tenant_id"] == ["can't be blank"]
    end

    test "returns 422 on invalid UUIDs", %{conn: conn} do
      conn =
        signed_post(conn, @tenant_calendar_endpoint, %{
          "tenant_id" => "not-a-uuid",
          "calendar_id" => "also-bad"
        })

      json = json_response(conn, 422)

      # assert json["status"] == "error"
      # assert json["message"] == "validation failed"
      # assert json["details"]["tenant_id"] == ["is invalid"]
      # assert json["details"]["calendar_id"] == ["is invalid"]
    end
  end
end
