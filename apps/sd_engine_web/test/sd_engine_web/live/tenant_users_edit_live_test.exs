defmodule SDWeb.TenantUsersEditLive.FormTest do
  use SDWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  import SD.TenantsFixtures
  import SD.AccountsFixtures

  describe "TenantUsersEditLive.Form" do
    setup [:log_in_admin]

    test "renders edit form with tenant and user info", %{conn: conn} do
      tenant = tenant_fixture()
      user = user_fixture()

      {:ok, _} =
        SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: user.id, role: :guest})

      {:ok, _lv, html} = live(conn, ~p"/tenants/#{tenant.id}/users/#{user.id}/edit")

      assert html =~ "Edit User Role"
      assert html =~ user.name
      assert html =~ user.email
    end

    test "updates role successfully and redirects", %{conn: conn} do
      tenant = tenant_fixture()
      user = user_fixture()

      {:ok, tenant_user} =
        SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: user.id, role: :guest})

      {:ok, lv, _html} = live(conn, ~p"/tenants/#{tenant.id}/users/#{user.id}/edit")

      form =
        form(lv, "#tenant-user-edit-form", %{
          "tenant_user" => %{"role" => "admin"}
        })

      # This triggers the push_navigate
      render_submit(form)

      # ✅ Use LiveView’s assert_redirect/2
      assert_redirect(lv, ~p"/tenants/#{tenant.id}/users")

      # Ensure DB was updated
      tenant_user = SD.Repo.reload!(tenant_user)
      assert tenant_user.role == :admin
    end
  end
end
