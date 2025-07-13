defmodule SDWeb.Plugs.AdminAuthTest do
  use SDWeb.ConnCase

  alias SDWeb.Plugs.AdminAuth

  describe "require_authenticated_admin/2" do
    test "redirects to login when not authenticated", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        # Add this line
        |> fetch_flash()
        |> AdminAuth.require_authenticated_admin([])

      assert redirected_to(conn) == ~p"/"
      assert conn.halted
    end

    test "continues when authenticated", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        # Add this line
        |> fetch_flash()
        |> put_session(:current_admin_id, "admin")
        |> AdminAuth.require_authenticated_admin([])

      refute conn.halted
    end
  end

  describe "redirect_if_admin_is_authenticated/2" do
    test "continues when not authenticated", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        # Add this line
        |> fetch_flash()
        |> AdminAuth.redirect_if_admin_is_authenticated([])

      refute conn.halted
    end

    test "redirects to tiers when authenticated", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        # Add this line
        |> fetch_flash()
        |> put_session(:current_admin_id, "admin")
        |> AdminAuth.redirect_if_admin_is_authenticated([])

      assert redirected_to(conn) == ~p"/accounts"
      assert conn.halted
    end
  end
end
