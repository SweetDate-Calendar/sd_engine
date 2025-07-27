defmodule SDWeb.SessionController do
  use SDWeb, :controller

  def create(conn, %{"admin" => %{"user_name" => user_name, "password" => password}}) do
    admin_username = System.get_env("ADMIN_USERNAME", "sd_admin")
    admin_password = System.get_env("ADMIN_PASSWORD", "sd_password")

    if user_name == admin_username && password == admin_password do
      conn
      |> put_session(:current_admin_id, "admin")
      |> put_flash(:info, "Welcome back!")
      |> redirect(to: ~p"/tenants")
    else
      conn
      |> put_flash(:error, "Invalid username or password")
      |> redirect(to: ~p"/")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Logged out successfully")
    |> redirect(to: ~p"/")
  end
end
