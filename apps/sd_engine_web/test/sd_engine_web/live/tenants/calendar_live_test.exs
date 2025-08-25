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

  describe "Tenant Show - calendar actions" do
    setup [:create_calendar, :log_in_admin]

    # test "displays calendar", %{conn: conn, tenant: tenant, calendar: calendar} do
    #   {:ok, _show_live, html} =
    #     live(conn, ~p"/tenants/#{tenant.id}/calendars/#{calendar}")

    #   assert html =~ "Show Calendar"
    #   assert html =~ calendar.name
    # end

    # test "navigates to edit calendar from tenant show", %{
    #   conn: conn,
    #   tenant: tenant,
    #   calendar: calendar
    # } do
    #   {:ok, lv, _html} = live(conn, ~p"/tenants/#{tenant.id}")

    #   lv
    #   |> element("#edit-calendar-#{calendar.id}")
    #   |> render_click()

    #   assert_redirect(
    #     lv,
    #     ~p"/tenants/#{tenant.id}/calendars/#{calendar}/edit?return_to=show_tenant"
    #   )
    # end

    test "deletes calendar from tenant show", %{conn: conn, tenant: tenant, calendar: calendar} do
      {:ok, lv, _html} = live(conn, ~p"/tenants/#{tenant.id}")

      # Ensure the row is present
      row_id = "calendars-#{calendar.id}"
      assert has_element?(lv, "##{row_id}")

      # Click the Delete link inside that row
      lv
      |> element("##{row_id} a", "Delete")
      |> render_click()

      # Row is removed from the stream/DOM
      refute has_element?(lv, "##{row_id}")

      # Optional: verify DB deletion
      assert is_nil(SD.Repo.get(SD.Calendars.Calendar, calendar.id))
    end
  end
end
