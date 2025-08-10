defmodule SDWeb.Tenants.CalendarLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.TenantsFixtures

  defp create_calendar(_context) do
    tenant = tenant_fixture()

    params = %{
      name: "some name-#{System.unique_integer([:positive])}",
      color_theme: "some color_theme",
      visibility: :public
    }

    {:ok, calendar} = SD.Tenants.add_calendar(tenant.id, params)
    calendar = SD.Repo.preload(calendar, :tenants)

    %{calendar: calendar, tenant: tenant}
  end

  describe "Show" do
    setup [:create_calendar, :log_in_admin]

    test "displays calendar", %{conn: conn, tenant: tenant, calendar: calendar} do
      {:ok, _show_live, html} =
        live(conn, ~p"/tenants/#{tenant.id}/calendars/#{calendar}")

      assert html =~ "Show Calendar"
      assert html =~ calendar.name
    end
  end
end
