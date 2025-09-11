defmodule SDRest.Join.CalendarUsersControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  # import SDRest.ControllerHelpers
  import SD.CalendarsFixtures
  import SD.AccountsFixtures

  describe "POST /api/v1/join/calendars/:calendar_id/users" do
    test "creates a calendar user", %{conn: conn} do
      calendar = calendar_fixture()
      user = user_fixture()

      body = %{
        "user_id" => user.id,
        "role" => "admin"
      }

      endpoint = "/api/v1/join/calendars/#{calendar.id}/users"

      conn = signed_post(conn, endpoint, body)
      json = json_response(conn, 201)

      assert json["status"] == "ok"
      assert json["user"]["role"] == "admin"
    end

    test "fails when user_id and role is id missing", %{conn: conn} do
      calendar = calendar_fixture()
      endpoint = "/api/v1/join/calendars/#{calendar.id}/users"
      conn = signed_post(conn, endpoint, %{})
      json = json_response(conn, 422)

      assert json == %{
               "message" => %{"role" => ["can't be blank"], "user_id" => ["can't be blank"]},
               "status" => "error"
             }
    end
  end

  describe "PATCH /api/v1/join/calendars/:calendar_id/users/:id" do
    test "updates a calendar user", %{conn: conn} do
      calendar_user = SD.CalendarsFixtures.calendar_user_fixture()

      update_body = %{
        "role" => "owner"
      }

      endpoint =
        "/api/v1/join/calendars/#{calendar_user.calendar_id}/users/#{calendar_user.user_id}"

      conn = signed_patch(conn, endpoint, update_body)
      json = json_response(conn, 200)

      assert json["status"] == "ok"
      assert json["user"]["id"] == calendar_user.user_id
      assert json["user"]["role"] == "owner"
    end

    test "returns 404 when calendar_user not found", %{conn: conn} do
      endpoint =
        "/api/v1/join/calendars/00000000-0000-0000-0000-000000000000/users/00000000-0000-0000-0000-000000000000"

      conn =
        signed_put(conn, endpoint, %{"role" => "admin"})

      json = json_response(conn, 404)

      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end

  describe "DELETE /calendar_users/:id" do
    test "deletes a calendar user join", %{conn: conn} do
      calendar_user = SD.CalendarsFixtures.calendar_user_fixture()

      endpoint =
        "/api/v1/join/calendars/#{calendar_user.calendar_id}/users/#{calendar_user.user_id}"

      conn = signed_delete(conn, endpoint)
      json = json_response(conn, 200)

      assert json["status"] == "ok"
    end

    test "returns 404 when join not found", %{conn: conn} do
      endpoint =
        "/api/v1/join/calendars/00000000-0000-0000-0000-000000000000/users/00000000-0000-0000-0000-000000000000"

      conn = signed_delete(conn, endpoint)
      json = json_response(conn, 404)

      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end
end
