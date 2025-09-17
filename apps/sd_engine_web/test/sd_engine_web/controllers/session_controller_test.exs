defmodule SDWeb.SessionControllerTest do
  use SDWeb.ConnCase, async: true

  describe "POST /login (create)" do
    test "logs in with correct credentials", %{conn: conn} do
      # Override env vars just for this test
      System.put_env("ADMIN_USERNAME", "test_admin")
      System.put_env("ADMIN_PASSWORD", "secret")

      conn =
        post(conn, ~p"/login", %{
          "admin" => %{"user_name" => "test_admin", "password" => "secret"}
        })

      # Assert redirected
      assert redirected_to(conn) == ~p"/tenants"

      # Session should be set
      assert get_session(conn, :current_admin_id) == "admin"

      # Flash should contain welcome
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "rejects invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/login", %{
          "admin" => %{"user_name" => "wrong", "password" => "bad"}
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid username or password"
      refute get_session(conn, :current_admin_id)
    end

    test "uses default fallback env vars when none are set", %{conn: conn} do
      # Clear env vars so defaults are used
      System.delete_env("ADMIN_USERNAME")
      System.delete_env("ADMIN_PASSWORD")

      conn =
        post(conn, ~p"/login", %{
          "admin" => %{"user_name" => "sd_admin", "password" => "sd_password"}
        })

      assert redirected_to(conn) == ~p"/tenants"
      assert get_session(conn, :current_admin_id) == "admin"
    end
  end

  describe "DELETE /logout (delete)" do
    test "logs out and clears session", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{current_admin_id: "admin"})
        |> delete(~p"/logout")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
      refute get_session(conn, :current_admin_id)
    end
  end
end
