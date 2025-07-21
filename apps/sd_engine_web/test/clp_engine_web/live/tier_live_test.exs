defmodule SDWeb.TenantLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.TenantsFixtures
  import SD.CalendarsFixtures

  # @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_tenant(_) do
    tenant =
      tenant_fixture()
      |> SD.Repo.preload(:account)

    _calendar1 = calendar_fixture(%{tenant_id: tenant.id, name: "Calendar 1"})
    _calendar2 = calendar_fixture(%{tenant_id: tenant.id, name: "Calendar 2"})

    %{tenant: tenant, account: tenant.account}
  end

  describe "Show" do
    setup [:create_tenant, :log_in_admin]

    test "displays tenant", %{conn: conn, tenant: tenant, account: account} do
      {:ok, _show_live, html} = live(conn, ~p"/accounts/#{account}/tenants/#{tenant}")

      assert html =~ "Show Tenant"
      assert html =~ tenant.name
    end

    test "updates tenant", %{conn: conn, tenant: tenant, account: account} do
      {:ok, show_live, _html} = live(conn, ~p"/accounts/#{account}/tenants/#{tenant}")

      assert {:ok, form_live, _} =
               show_live
               |> element("#edit-tenant-#{tenant.id}", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/accounts/#{account}/tenants/#{tenant}/edit?return_to=show_tenant"
               )

      assert render(form_live) =~ "Edit Tenant"

      assert form_live
             |> form("#tenant-form", tenant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#tenant-form", tenant: @update_attrs)
               |> render_submit()
               |> follow_redirect(
                 conn,
                 ~p"/accounts/#{account}/tenants/#{tenant}"
               )

      html = render(show_live)
      assert html =~ "Tenant updated successfully"
      assert html =~ "some updated name"
    end
  end

  describe "Tenant calendars" do
    setup [:create_tenant, :log_in_admin]

    test "lists all calendars", %{conn: conn, tenant: tenant} do
      {:ok, _index_live, html} =
        live(conn, ~p"/accounts/#{tenant.account_id}/tenants/#{tenant.id}")

      tenant = tenant |> SD.Repo.preload(:calendars)

      assert html =~ "Calendars"

      for calendar <- tenant.calendars do
        assert html =~ calendar.name
      end
    end

    test "saves new calendar", %{conn: conn, tenant: tenant} do
      {:ok, show_live, _html} =
        live(conn, ~p"/accounts/#{tenant.account_id}/tenants/#{tenant.id}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "New Calendar")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/tenants/#{tenant}/calendars/new?return_to=show_tenant"
               )

      assert render(form_live) =~ "New Calendar"

      assert form_live
             |> form("#calendar-form", calendar: %{tenant_id: nil, name: nil})
             |> render_change() =~ "can&#39;t be blank"

      calendar_attrs = %{
        tenant_id: tenant.id,
        name: "some tenant calendar",
        visibility: :shared,
        color_theme: "pink"
      }

      assert {:ok, show_live, _html} =
               form_live
               |> form("#calendar-form", calendar: calendar_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts/#{tenant.account_id}/tenants/#{tenant.id}")

      html = render(show_live)
      assert html =~ "Calendar created successfully"
      assert html =~ "some tenant calendar"
    end

    test "updates calendar in listing", %{conn: conn, tenant: tenant} do
      calendar = calendar_fixture(%{tenant_id: tenant.id, name: "some tenant calendar name"})

      {:ok, show_live, _html} =
        live(conn, ~p"/accounts/#{tenant.account_id}/tenants/#{tenant.id}")

      assert {:ok, form_live, _html} =
               show_live
               |> element("#edit-calendar-#{calendar.id}", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/tenants/#{tenant.id}/calendars/#{calendar}/edit?return_to=show_tenant"
               )

      assert render(form_live) =~ "Edit Calendar"

      invalid_attrs = %{name: nil, color_theme: nil, visibility: nil}

      assert form_live
             |> form("#calendar-form", calendar: invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      update_attrs = %{
        name: "some updated tenant calendar name",
        color_theme: "dusty",
        visibility: :public
      }

      assert {:ok, show_live, _html} =
               form_live
               |> form("#calendar-form", calendar: update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts/#{tenant.account_id}/tenants/#{tenant.id}")

      html = render(show_live)
      assert html =~ "Calendar updated successfully"
      assert html =~ "some updated tenant calendar name"
    end

    test "deletes calendar in listing", %{conn: conn, tenant: tenant} do
      calendar = calendar_fixture(%{tenant_id: tenant.id, name: "some tenant calendar name"})

      {:ok, show_live, _html} =
        live(conn, ~p"/accounts/#{tenant.account_id}/tenants/#{tenant.id}")

      assert show_live |> element("#calendars-#{calendar.id} a", "Delete") |> render_click()
      refute has_element?(show_live, "#calendars-#{calendar.id}")
    end
  end
end
