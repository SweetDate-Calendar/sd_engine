defmodule SDRest.CalendarsControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  import Phoenix.ConnTest
  import SD.CalendarsFixtures

  @base "/api/v1/calendars"

  setup %{conn: conn} do
    calendar_fixture(%{name: "Alpha"})
    calendar_fixture(%{name: "Beta"})
    calendar_fixture(%{name: "Charlie"})

    {:ok, conn: conn}
  end

  describe "index" do
    test "GET /api/v1/calendars returns list of calendars", %{conn: conn} do
      conn = signed_get(conn, "/api/v1/calendars")

      %{"status" => "ok", "calendars" => cals, "limit" => 25, "offset" => 0} =
        json_response(conn, 200)

      assert Enum.map(cals, & &1["name"]) == ["Alpha", "Beta", "Charlie"]
    end

    test "respects limit and offset", %{conn: conn} do
      conn = signed_get(conn, "/api/v1/calendars?limit=2&offset=1")

      %{"status" => "ok", "calendars" => cals, "limit" => 2, "offset" => 1} =
        json_response(conn, 200)

      assert Enum.map(cals, & &1["name"]) == ["Beta", "Charlie"]
    end
  end

  describe "show" do
    test "GET /api/v1/calendars/:id returns calendar", %{conn: conn} do
      c = calendar_fixture(%{name: "Echo"})
      conn = signed_get(conn, "/api/v1/calendars/#{c.id}")

      %{"status" => "ok", "calendar" => jc} = json_response(conn, 200)
      assert jc["id"] == c.id
      assert jc["name"] == "Echo"
    end

    test "GET /api/v1/calendars/:id 404 when not found", %{conn: conn} do
      conn = signed_get(conn, "#{@base}/00000000-0000-0000-0000-000000000000")
      assert json_response(conn, 404)["status"] == "error"
    end
  end

  describe "create" do
    test "POST /api/v1/calendars creates calendar", %{conn: conn} do
      conn = signed_post(conn, "/api/v1/calendars", %{"name" => "Delta"})

      %{"status" => "ok", "calendar" => jc} = json_response(conn, 201)
      assert jc["name"] == "Delta"
      assert jc["id"]
    end

    test "POST /api/v1/calendars invalid params", %{conn: conn} do
      conn = signed_post(conn, "/api/v1/calendars", %{"name" => ""})

      json = json_response(conn, 422)
      assert json["status"] == "error"
      assert Map.has_key?(json["message"], "name")
      assert "can't be blank" in json["message"]["name"]
    end
  end

  describe "update" do
    test "PUT /api/v1/calendars/:id updates calendar", %{conn: conn} do
      c = calendar_fixture(%{name: "Foxtrot"})
      conn = signed_put(conn, "#{@base}/#{c.id}", %{"name" => "Updated"})

      %{"status" => "ok", "calendar" => jc} = json_response(conn, 200)
      assert jc["id"] == c.id
      assert jc["name"] == "Updated"
    end

    test "PUT /api/v1/calendars/:id returns 404", %{conn: conn} do
      conn = signed_put(conn, "#{@base}/00000000-0000-0000-0000-000000000000", %{"name" => "X"})
      assert json_response(conn, 404)["status"] == "error"
    end

    test "PUT /api/v1/calendars/:id returns 422", %{conn: conn} do
      c = calendar_fixture(%{name: "Zulu"})
      conn = signed_put(conn, "#{@base}/#{c.id}", %{"name" => ""})
      assert json_response(conn, 422)["status"] == "error"
    end
  end

  describe "delete" do
    test "DELETE /api/v1/calendars/:id deletes calendar", %{conn: conn} do
      c = calendar_fixture(%{name: "Golf"})
      conn = signed_delete(conn, "#{@base}/#{c.id}")

      %{"status" => "ok", "calendar" => %{"id" => id, "name" => name}} = json_response(conn, 200)
      assert id == c.id
      assert name == "Golf"

      conn2 = signed_get(build_conn(), "#{@base}/#{c.id}")
      assert json_response(conn2, 404)["status"] == "error"
    end

    test "DELETE /api/v1/calendars/:id not found", %{conn: conn} do
      conn = signed_delete(conn, "#{@base}/00000000-0000-0000-0000-000000000000")
      assert json_response(conn, 404)["status"] == "error"
    end
  end
end
