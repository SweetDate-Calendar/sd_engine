defmodule SDRest.TenantSweetDateControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  import Phoenix.ConnTest
  import SD.TenantsFixtures
  import SD.SweetDateFixtures

  @tenants_base "/api/v1/tenants"

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  describe "index (GET /tenants/:tenant_id/calendars)" do
    test "lists calendars for the given tenant with default pagination", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team A"})
      c1 = calendar_fixture(%{name: "Alpha Cal", color_theme: "blue"})
      c2 = calendar_fixture(%{name: "Beta Cal", color_theme: "red"})

      _ = SD.Tenants.create_tenant_calendar(%{"tenant_id" => tenant.id, "calendar_id" => c1.id})
      _ = SD.Tenants.create_tenant_calendar(%{"tenant_id" => tenant.id, "calendar_id" => c2.id})

      path = "#{@tenants_base}/#{tenant.id}/calendars"
      conn = signed_get(conn, path)

      %{"status" => "ok", "calendars" => calendars} = json_response(conn, 200)

      assert length(calendars) == 2

      Enum.each(calendars, fn c ->
        assert is_binary(c["id"])
        assert is_binary(c["name"])
        assert is_binary(c["color_theme"])
        assert is_binary(c["visibility"])
        assert is_binary(c["inserted_at"])
        assert is_binary(c["updated_at"])
      end)

      names = calendars |> Enum.map(& &1["name"]) |> Enum.sort()
      assert names == ["Alpha Cal", "Beta Cal"]
    end

    test "respects limit & offset", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team B"})
      c1 = calendar_fixture(%{name: "A"})
      c2 = calendar_fixture(%{name: "B"})
      c3 = calendar_fixture(%{name: "C"})

      _ = SD.Tenants.create_tenant_calendar(%{"tenant_id" => tenant.id, "calendar_id" => c1.id})
      _ = SD.Tenants.create_tenant_calendar(%{"tenant_id" => tenant.id, "calendar_id" => c2.id})
      _ = SD.Tenants.create_tenant_calendar(%{"tenant_id" => tenant.id, "calendar_id" => c3.id})

      conn = signed_get(conn, "#{@tenants_base}/#{tenant.id}/calendars?limit=2&offset=1")

      %{"status" => "ok", "calendars" => calendars} = json_response(conn, 200)
      assert length(calendars) == 2
    end

    test "404 when tenant id invalid or not found", %{conn: conn} do
      conn1 = signed_get(conn, "#{@tenants_base}/not-a-uuid/calendars")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn1, 404)

      conn2 =
        signed_get(conn, "#{@tenants_base}/00000000-0000-0000-0000-000000000000/calendars")

      assert %{"status" => "error", "message" => "not found"} = json_response(conn2, 404)
    end
  end

  describe "create (POST /tenants/:tenant_id/calendars)" do
    test "links calendar and returns the calendar view", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team C"})
      calendar = calendar_fixture(%{name: "Team Calendar", color_theme: "blue"})

      path = "#{@tenants_base}/#{tenant.id}/calendars"
      conn = signed_post(conn, path, %{"calendar_id" => calendar.id})

      %{"status" => "ok", "calendar" => c} = json_response(conn, 201)

      assert c["id"] == calendar.id
      assert c["name"] == "Team Calendar"
      assert c["color_theme"] == "blue"
      assert is_binary(c["visibility"])
      assert is_binary(c["inserted_at"])
      assert is_binary(c["updated_at"])
    end

    test "422 when payload invalid (missing calendar_id)", %{conn: conn} do
      tenant = tenant_fixture()

      conn = signed_post(conn, "#{@tenants_base}/#{tenant.id}/calendars", %{})

      %{
        "status" => "error",
        "message" => _msg,
        "error_code" => _code,
        "fields" => _fields
      } = json_response(conn, 422)
    end

    test "404 when tenant invalid/not found", %{conn: conn} do
      conn1 =
        signed_post(conn, "#{@tenants_base}/not-a-uuid/calendars", %{
          "calendar_id" => Ecto.UUID.generate()
        })

      assert %{"status" => "error", "message" => "not found"} = json_response(conn1, 404)

      conn2 =
        signed_post(
          conn,
          "#{@tenants_base}/00000000-0000-0000-0000-000000000000/calendars",
          %{"calendar_id" => Ecto.UUID.generate()}
        )

      assert %{"status" => "error", "message" => "not found"} = json_response(conn2, 404)
    end
  end

  describe "show (GET /tenants/:tenant_id/calendars/:id)" do
    test "returns the calendar", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team D"})
      calendar = calendar_fixture(%{name: "Roadmap", color_theme: "green"})

      _ =
        SD.Tenants.create_tenant_calendar(%{
          "tenant_id" => tenant.id,
          "calendar_id" => calendar.id
        })

      conn = signed_get(conn, "#{@tenants_base}/#{tenant.id}/calendars/#{calendar.id}")

      %{"status" => "ok", "calendar" => c} = json_response(conn, 200)

      assert c["id"] == calendar.id
      assert c["name"] == "Roadmap"
      assert c["color_theme"] == "green"
      assert is_binary(c["visibility"])
    end

    test "404 when calendar is not linked to tenant", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team E"})
      calendar = calendar_fixture(%{name: "Unlinked"})

      conn = signed_get(conn, "#{@tenants_base}/#{tenant.id}/calendars/#{calendar.id}")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn, 404)
    end
  end

  describe "delete (DELETE /tenants/:tenant_id/calendars/:id)" do
    test "deletes tenant_calendar link and returns status ok", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team H"})
      calendar = calendar_fixture(%{name: "Sprint Plan"})

      {:ok, _tc} =
        SD.Tenants.create_tenant_calendar(%{
          "tenant_id" => tenant.id,
          "calendar_id" => calendar.id
        })

      conn = signed_delete(conn, "#{@tenants_base}/#{tenant.id}/calendars/#{calendar.id}")

      %{"status" => "ok"} = json_response(conn, 200)

      # Ensure calendar no longer listed
      conn2 = signed_get(build_conn(), "#{@tenants_base}/#{tenant.id}/calendars")
      %{"status" => "ok", "calendars" => list2} = json_response(conn2, 200)
      refute Enum.any?(list2, &(&1["id"] == calendar.id))
    end

    test "404 when tenant or calendar id invalid/not found", %{conn: conn} do
      conn1 = signed_delete(conn, "#{@tenants_base}/not-a-uuid/calendars/#{Ecto.UUID.generate()}")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn1, 404)

      tenant = tenant_fixture()

      conn2 =
        signed_delete(conn, "#{@tenants_base}/#{tenant.id}/calendars/#{Ecto.UUID.generate()}")

      assert %{"status" => "error", "message" => "not found"} = json_response(conn2, 404)
    end
  end
end
