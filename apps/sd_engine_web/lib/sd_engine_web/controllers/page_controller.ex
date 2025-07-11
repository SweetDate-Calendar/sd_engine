defmodule SDWeb.PageController do
  use SDWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
