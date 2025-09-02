defmodule SDRest.Join.CalendarUsersControllerTest do
  use SDRest.ConnCase, async: true

  alias SD.SweetDate
  alias SD.Accounts

  @join_endpoint "/api/v1/join/calendar_users"

  describe "POST /join/calendar_users" do
    test "creates a calendar-user join", %{conn: conn} do
      calendar = SD.SweetDateFixtures.calendar_fixture()
      user = SD.AccountsFixtures.user_fixture()

      body = %{
        "calendar_id" => calendar.id,
        "user_id" => user.id,
        "role" => "admin"
      }

      conn = signed_post(conn, @join_endpoint, body)

      json = json_response(conn, 201)
      assert json["status"] == "ok"
      assert join = json["calendar_user"]
      assert join["calendar_id"] == calendar.id
      assert join["user_id"] == user.id
      assert join["role"] == "admin"
    end

    test "returns 422 on missing fields", %{conn: conn} do
      conn = signed_post(conn, @join_endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert Map.has_key?(json["details"], "calendar_id")
      assert Map.has_key?(json["details"], "user_id")
    end
  end

  describe "PATCH /join/calendar_users/:id" do
    test "updates calendar-user role", %{conn: conn} do
      calendar = SD.SweetDateFixtures.calendar_fixture()
      user = SD.AccountsFixtures.user_fixture()

      {:ok, join} =
        SweetDate.create_calendar_user(%{
          "calendar_id" => calendar.id,
          "user_id" => user.id,
          "role" => "guest"
        })

      conn =
        signed_patch(conn, "#{@join_endpoint}/#{join.id}", %{
          "role" => "owner"
        })

      json = json_response(conn, 200)
      assert json["status"] == "ok"
      assert json["calendar_user"]["role"] == "owner"
    end

    test "returns 404 for nonexistent join", %{conn: conn} do
      conn =
        signed_patch(conn, "#{@join_endpoint}/00000000-0000-0000-0000-000000000000", %{
          "role" => "admin"
        })

      json = json_response(conn, 404)
      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end

  describe "DELETE /join/calendar_users/:id" do
    test "deletes calendar-user join", %{conn: conn} do
      calendar = SD.SweetDateFixtures.calendar_fixture()
      user = SD.AccountsFixtures.user_fixture()

      {:ok, join} =
        SweetDate.create_calendar_user(%{
          "calendar_id" => calendar.id,
          "user_id" => user.id,
          "role" => "admin"
        })

      conn = signed_delete(conn, "#{@join_endpoint}/#{join.id}")
      json = json_response(conn, 200)

      assert json["status"] == "ok"
      assert json["calendar_user"]["id"] == join.id
    end

    test "returns 404 for nonexistent join", %{conn: conn} do
      conn = signed_delete(conn, "#{@join_endpoint}/00000000-0000-0000-0000-000000000000")
      json = json_response(conn, 404)

      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end
end
