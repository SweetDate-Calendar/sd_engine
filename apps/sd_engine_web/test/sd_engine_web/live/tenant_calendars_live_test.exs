defmodule SDWeb.TenantCalendarsLive.FormTest do
  use SDWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  import SD.TenantsFixtures
  import SD.CalendarsFixtures

  describe "TenantCalendarsLive.Form" do
    setup [:log_in_admin]

    test "mounts and shows tenant info", %{conn: conn} do
      tenant = tenant_fixture()
      {:ok, _lv, html} = live(conn, ~p"/tenants/#{tenant.id}/calendars")

      assert html =~ "Calendars"
      assert html =~ tenant.name
    end

    test "assigns a calendar to tenant", %{conn: conn} do
      tenant = tenant_fixture()
      calendar = calendar_fixture()

      {:ok, lv, _html} = live(conn, ~p"/tenants/#{tenant.id}/calendars")

      form =
        form(lv, "#tenant-calendar-form", %{
          "tenant_calendar" => %{"calendar_id" => calendar.id}
        })

      result = render_submit(form)

      assert result =~ "Calendar assigned successfully"
      assert result =~ calendar.name
    end

    test "shows error when calendar already assigned", %{conn: conn} do
      tenant = tenant_fixture()
      calendar = calendar_fixture()

      # first assignment succeeds
      {:ok, lv, _} = live(conn, ~p"/tenants/#{tenant.id}/calendars")

      render_submit(
        form(lv, "#tenant-calendar-form", %{"tenant_calendar" => %{"calendar_id" => calendar.id}})
      )

      # second assignment triggers unique constraint
      {:ok, lv, _} = live(conn, ~p"/tenants/#{tenant.id}/calendars")

      result =
        render_submit(
          form(lv, "#tenant-calendar-form", %{
            "tenant_calendar" => %{"calendar_id" => calendar.id}
          })
        )

      assert result =~ "This calendar is already assigned to the tenant"
    end

    test "removes an assigned calendar", %{conn: conn} do
      tenant = tenant_fixture()
      calendar = calendar_fixture()

      {:ok, lv, _} = live(conn, ~p"/tenants/#{tenant.id}/calendars")

      render_submit(
        form(lv, "#tenant-calendar-form", %{"tenant_calendar" => %{"calendar_id" => calendar.id}})
      )

      # re-mount to show table with assigned calendar
      {:ok, lv, _} = live(conn, ~p"/tenants/#{tenant.id}/calendars")

      # click the Remove link
      result = render_click(element(lv, "a", "Remove"))

      assert result =~ "Calendar removed successfully"
      refute render(lv) =~ ~s(id="calendar-name-#{calendar.id}")
    end
  end
end
