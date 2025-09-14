defmodule SDWeb.TenantUsersLive.FormTest do
  use SDWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  import SD.TenantsFixtures
  import SD.AccountsFixtures

  describe "TenantUsersLive.Form" do
    setup [:log_in_admin]

    test "mounts and shows tenant info", %{conn: conn} do
      tenant = tenant_fixture()
      {:ok, _lv, html} = live(conn, ~p"/tenants/#{tenant.id}/users")

      assert html =~ "Users"
      assert html =~ tenant.name
    end

    test "assigns a user to tenant", %{conn: conn} do
      tenant = tenant_fixture()
      user = user_fixture()

      {:ok, lv, _html} = live(conn, ~p"/tenants/#{tenant.id}/users")

      form =
        form(lv, "#tenant-user-form", %{
          "tenant_user" => %{"user_id" => user.id, "role" => "admin"}
        })

      result = render_submit(form)

      assert result =~ "User assigned successfully"
      assert result =~ user.name
      assert result =~ "admin"
    end

    test "shows error when user already assigned", %{conn: conn} do
      tenant = tenant_fixture()
      user = user_fixture()

      # first assignment succeeds
      {:ok, lv, _} = live(conn, ~p"/tenants/#{tenant.id}/users")

      render_submit(
        form(lv, "#tenant-user-form", %{
          "tenant_user" => %{"user_id" => user.id, "role" => "guest"}
        })
      )

      # second assignment triggers unique constraint
      {:ok, lv, _} = live(conn, ~p"/tenants/#{tenant.id}/users")

      result =
        render_submit(
          form(lv, "#tenant-user-form", %{
            "tenant_user" => %{"user_id" => user.id, "role" => "guest"}
          })
        )

      assert result =~ "This user is already assigned to the tenant"
    end

    test "removes an assigned user", %{conn: conn} do
      tenant = tenant_fixture()
      user = user_fixture()

      {:ok, lv, _} = live(conn, ~p"/tenants/#{tenant.id}/users")

      render_submit(
        form(lv, "#tenant-user-form", %{
          "tenant_user" => %{"user_id" => user.id, "role" => "owner"}
        })
      )

      # re-mount to show table with assigned user
      {:ok, lv, _} = live(conn, ~p"/tenants/#{tenant.id}/users")

      # click the Remove link
      result = render_click(element(lv, "a", "Remove"))

      assert result =~ "User removed successfully"
      refute render(lv) =~ ~s(id="user-name-#{user.id}")
    end
  end
end
