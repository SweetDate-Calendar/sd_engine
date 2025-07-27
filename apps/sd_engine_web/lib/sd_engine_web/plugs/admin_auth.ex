defmodule SDWeb.Plugs.AdminAuth do
  import Plug.Conn
  import Phoenix.Controller

  use SDWeb, :verified_routes

  def init(opts), do: opts

  @doc """
  Plug for routes that require the admin to be authenticated.
  """
  def require_authenticated_admin(conn, _opts) do
    if get_session(conn, :current_admin_id) do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  @doc """
  Plug for routes that require the admin to not be authenticated.
  """
  def redirect_if_admin_is_authenticated(conn, _opts) do
    if get_session(conn, :current_admin_id) do
      conn
      |> redirect(to: ~p"/tenants")
      |> halt()
    else
      conn
    end
  end
end
