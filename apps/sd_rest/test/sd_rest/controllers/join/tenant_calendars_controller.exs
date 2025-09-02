defmodule SDRest.Join.TenantCalendarsControllerTest do
  use SDRest.ConnCase, async: true

  alias SD.Tenants
  alias SD.SweetDate

  @join_endpoint "/api/v1/join/tenant_calendars"

  describe "POST /join/tenant_calendars" do
    test "creates a tenant-calendar join", %{conn: conn} do
      # Setup test data
      tenant = SD.TenantsFixtures.tenant_fixture(%{name: "TenantJoin #{System.unique_integer()}"})

      calendar =
        SD.SweetDateFixtures.calendar_fixture(%{name: "CalendarJoin #{System.unique_integer()}"})

      body = %{
        "tenant_id" => tenant.id,
        "calendar_id" => calendar.id
      }

      conn = signed_post(conn, @join_endpoint, body)

      assert json = json_response(conn, 201)
      assert json["status"] == "ok"
      assert join = json["tenant_calendar"]
      assert join["tenant_id"] == tenant.id
      assert join["calendar_id"] == calendar.id
      assert join["id"] != nil
    end

    test "returns 422 on missing fields", %{conn: conn} do
      conn = signed_post(conn, @join_endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert Map.has_key?(json["details"], "tenant_id")
      assert Map.has_key?(json["details"], "calendar_id")
    end
  end

  describe "DELETE /join/tenant_calendars/:id" do
    test "deletes an existing join", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture()
      calendar = SD.SweetDateFixtures.calendar_fixture()

      {:ok, join} =
        Tenants.create_tenant_calendar(%{
          "tenant_id" => tenant.id,
          "calendar_id" => calendar.id
        })

      conn = signed_delete(conn, "#{@join_endpoint}/#{join.id}")

      json = json_response(conn, 200)
      assert json["status"] == "ok"
      assert json["tenant_calendar"]["id"] == join.id
    end

    test "returns 404 for nonexistent join", %{conn: conn} do
      conn = signed_delete(conn, "#{@join_endpoint}/00000000-0000-0000-0000-000000000000")
      json = json_response(conn, 404)

      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end

  describe "POST /join/tenant_calendars — validation" do
    test "returns 422 on missing both tenant_id and calendar_id", %{conn: conn} do
      conn = signed_post(conn, @join_endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert json["details"]["tenant_id"] == ["can't be blank"]
      assert json["details"]["calendar_id"] == ["can't be blank"]
    end

    test "returns 422 on missing calendar_id", %{conn: conn} do
      tenant = SD.TenantsFixtures.tenant_fixture()

      conn =
        signed_post(conn, @join_endpoint, %{
          "tenant_id" => tenant.id
        })

      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert json["details"]["calendar_id"] == ["can't be blank"]
    end

    test "returns 422 on missing tenant_id", %{conn: conn} do
      calendar = SD.SweetDateFixtures.calendar_fixture()

      conn =
        signed_post(conn, @join_endpoint, %{
          "calendar_id" => calendar.id
        })

      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert json["details"]["tenant_id"] == ["can't be blank"]
    end

    test "returns 422 on invalid UUIDs", %{conn: conn} do
      conn =
        signed_post(conn, @join_endpoint, %{
          "tenant_id" => "not-a-uuid",
          "calendar_id" => "also-bad"
        })

      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert json["details"]["tenant_id"] == ["is invalid"]
      assert json["details"]["calendar_id"] == ["is invalid"]
    end
  end
end
