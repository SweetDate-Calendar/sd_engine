defmodule SDWeb.TenantLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.TenantsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_tenant(_) do
    tenant = tenant_fixture()
    %{tenant: tenant}
  end

  describe "Index" do
    setup [:create_tenant, :log_in_admin]

    test "lists all tenants", %{conn: conn, tenant: tenant} do
      {:ok, _index_live, html} = live(conn, ~p"/tenants")

      assert html =~ "Listing Tenants"
      assert html =~ tenant.name
    end

    test "saves new tenant", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tenants")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Tenant")
               |> render_click()
               |> follow_redirect(conn, ~p"/tenants/new")

      assert render(form_live) =~ "New Tenant"

      assert form_live
             |> form("#tenant-form", tenant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#tenant-form", tenant: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tenants")

      html = render(index_live)
      assert html =~ "Tenant created successfully"
      assert html =~ "some name"
    end

    test "updates tenant in listing", %{conn: conn, tenant: tenant} do
      {:ok, index_live, _html} = live(conn, ~p"/tenants")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#tenants-#{tenant.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/tenants/#{tenant}/edit")

      assert render(form_live) =~ "Edit Tenant"

      assert form_live
             |> form("#tenant-form", tenant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#tenant-form", tenant: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tenants")

      html = render(index_live)
      assert html =~ "Tenant updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes tenant in listing", %{conn: conn, tenant: tenant} do
      {:ok, index_live, _html} = live(conn, ~p"/tenants")

      assert index_live |> element("#tenants-#{tenant.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tenants-#{tenant.id}")
    end
  end

  describe "Show" do
    setup [:create_tenant, :log_in_admin]

    test "displays tenant", %{conn: conn, tenant: tenant} do
      {:ok, _show_live, html} = live(conn, ~p"/tenants/#{tenant}")
      assert html =~ "Show Tenant"
      assert html =~ tenant.name
    end

    test "updates tenant and returns to show", %{conn: conn, tenant: tenant} do
      {:ok, show_live, _html} = live(conn, ~p"/tenants/#{tenant}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/tenants/#{tenant}/edit?return_to=show")

      assert render(form_live) =~ "Edit Tenant"

      assert form_live
             |> form("#tenant-form", tenant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#tenant-form", tenant: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/tenants/#{tenant}")

      html = render(show_live)
      assert html =~ "Tenant updated successfully"
      assert html =~ "some updated name"
    end
  end
end
