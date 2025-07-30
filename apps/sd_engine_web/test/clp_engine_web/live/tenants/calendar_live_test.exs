defmodule SDWeb.Tenants.CalendarLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.TenantsFixtures

  defp create_calendar(_) do
    tenant = tenant_fixture()

    calendar_attrs =
      %{
        color_theme: "some color_theme",
        name: "some name#{System.unique_integer()}",
        visibility: :public
      }

    {:ok, %{calendar: calendar, tenant_calendar: _tenant_calendar}} =
      SD.Tenants.add_calendar(tenant.id, calendar_attrs)

    calendar =
      calendar
      |> SD.Repo.preload(:tenants)

    %{tenant: tenant, calendar: calendar}
  end

  # describe "Index" do
  #   setup [:create_calendar]

  #   test "lists all calendars", %{conn: conn, calendar: calendar} do
  #     {:ok, _index_live, html} = live(conn, ~p"/tenants/#{tenant_id}/calendars")

  #     assert html =~ "Listing Calendars"
  #     assert html =~ calendar.name
  #   end

  #   test "saves new calendar", %{conn: conn} do
  #     {:ok, index_live, _html} = live(conn, ~p"/tenants/#{tenant_id}/calendars")

  #     assert {:ok, form_live, _} =
  #              index_live
  #              |> element("a", "New Calendar")
  #              |> render_click()
  #              |> follow_redirect(conn, ~p"/tenants/#{tenant_id}/calendars/new")

  #     assert render(form_live) =~ "New Calendar"

  #     assert form_live
  #            |> form("#calendar-form", calendar: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert {:ok, index_live, _html} =
  #              form_live
  #              |> form("#calendar-form", calendar: create_attrs())
  #              |> render_submit()
  #              |> follow_redirect(conn, ~p"/tenants/#{tenant_id}/calendars")

  #     html = render(index_live)
  #     assert html =~ "Calendar created successfully"
  #     assert html =~ "some name"
  #   end

  #   test "updates calendar in listing", %{conn: conn, calendar: calendar} do
  #     {:ok, index_live, _html} = live(conn, ~p"/tenants/#{tenant_id}/calendars")

  #     assert {:ok, form_live, _html} =
  #              index_live
  #              |> element("#calendars-#{calendar.id} a", "Edit")
  #              |> render_click()
  #              |> follow_redirect(conn, ~p"/tenants/#{tenant_id}/calendars/#{calendar}/edit")

  #     assert render(form_live) =~ "Edit Calendar"

  #     assert form_live
  #            |> form("#calendar-form", calendar: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert {:ok, index_live, _html} =
  #              form_live
  #              |> form("#calendar-form", calendar: @update_attrs)
  #              |> render_submit()
  #              |> follow_redirect(conn, ~p"/tenants/#{tenant_id}/calendars")

  #     html = render(index_live)
  #     assert html =~ "Calendar updated successfully"
  #     assert html =~ "some updated name"
  #   end

  #   test "deletes calendar in listing", %{conn: conn, calendar: calendar} do
  #     {:ok, index_live, _html} = live(conn, ~p"/tenants/#{tenant_id}/calendars")

  #     assert index_live |> element("#calendars-#{calendar.id} a", "Delete") |> render_click()
  #     refute has_element?(index_live, "#calendars-#{calendar.id}")
  #   end
  # end

  describe "Show" do
    setup [:create_calendar, :log_in_admin]

    test "displays calendar", %{conn: conn, tenant: tenant, calendar: calendar} do
      {:ok, _show_live, html} =
        live(conn, ~p"/tenants/#{tenant.id}/calendars/#{calendar}")

      assert html =~ "Show Calendar"
      assert html =~ calendar.name
    end

    # test "updates calendar and returns to show", %{conn: conn, calendar: calendar} do
    #   {:ok, show_live, _html} =
    #     live(conn, ~p"/tenants/#{calendar.tenant_id}/calendars/#{calendar}")

    #   assert {:ok, form_live, _} =
    #            show_live
    #            |> element("a", "Edit")
    #            |> render_click()
    #            |> follow_redirect(
    #              conn,
    #              ~p"/tenants/#{calendar.tenant_id}/calendars/#{calendar}/edit?return_to=show_calendar"
    #            )

    #   assert render(form_live) =~ "Edit Calendar"

    #   assert form_live
    #          |> form("#calendar-form", calendar: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   assert {:ok, show_live, _html} =
    #            form_live
    #            |> form("#calendar-form", calendar: @update_attrs)
    #            |> render_submit()
    #            |> follow_redirect(conn, ~p"/tenants/#{calendar.tenant_id}/calendars/#{calendar}")

    #   html = render(show_live)
    #   assert html =~ "Calendar updated successfully"
    #   assert html =~ "some updated name"
    # end
  end
end
