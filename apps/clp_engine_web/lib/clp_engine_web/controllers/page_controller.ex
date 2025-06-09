defmodule CLPWeb.PageController do
  use CLPWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
