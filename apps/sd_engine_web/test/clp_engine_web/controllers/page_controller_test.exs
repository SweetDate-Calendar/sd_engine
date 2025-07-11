defmodule CLPWeb.PageControllerTest do
  use CLPWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "SD - Headless Calendar"
  end
end
