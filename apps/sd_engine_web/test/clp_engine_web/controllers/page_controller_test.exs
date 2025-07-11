defmodule SDWeb.PageControllerTest do
  use SDWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "SD - Headless Calendar"
  end
end
