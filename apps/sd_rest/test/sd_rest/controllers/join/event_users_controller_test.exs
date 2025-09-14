defmodule SDRest.Join.EventUsersControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  import SD.CalendarsFixtures
  import SD.AccountsFixtures

  describe "POST /api/v1/join/events/:event_id/users" do
    test "creates an event_user", %{conn: conn} do
      event = event_fixture()
      user = user_fixture()

      body = %{
        "user_id" => user.id,
        "role" => "organizer",
        "status" => "accepted"
      }

      endpoint = "/api/v1/join/events/#{event.id}/users"

      conn = signed_post(conn, endpoint, body)
      json = json_response(conn, 201)

      assert json["status"] == "ok"
      assert json["user"]["role"] == "organizer"
      assert json["user"]["status"] == "accepted"
    end

    test "set the role by default", %{conn: conn} do
      event = event_fixture()
      user = user_fixture()

      body = %{
        "user_id" => user.id
      }

      endpoint = "/api/v1/join/events/#{event.id}/users"

      conn = signed_post(conn, endpoint, body)
      json = json_response(conn, 201)

      assert json["status"] == "ok"
      assert json["user"]["role"] == "attendee"
      assert json["user"]["status"] == "invited"
    end

    test "fails when user_id are missing", %{conn: conn} do
      event = event_fixture()
      endpoint = "/api/v1/join/events/#{event.id}/users"

      conn = signed_post(conn, endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"]["user_id"] == ["can't be blank"]
    end
  end

  describe "PATCH /api/v1/join/events/:event_id/users/:id" do
    test "updates an event_user", %{conn: conn} do
      event_user = SD.CalendarsFixtures.event_user_fixture()

      update_body = %{
        "role" => "guest",
        "status" => "declined"
      }

      endpoint =
        "/api/v1/join/events/#{event_user.event_id}/users/#{event_user.user_id}"

      conn = signed_patch(conn, endpoint, update_body)
      json = json_response(conn, 200)

      assert json["status"] == "ok"
      assert json["user"]["id"] == event_user.user_id
      assert json["user"]["role"] == "guest"
      assert json["user"]["status"] == "declined"
    end

    test "returns 404 when event_user not found", %{conn: conn} do
      endpoint =
        "/api/v1/join/events/00000000-0000-0000-0000-000000000000/users/00000000-0000-0000-0000-000000000000"

      conn = signed_patch(conn, endpoint, %{"role" => "attendee"})
      json = json_response(conn, 404)

      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end

  describe "DELETE /api/v1/join/events/:event_id/users/:id" do
    test "deletes an event_user", %{conn: conn} do
      event_user = SD.CalendarsFixtures.event_user_fixture()

      endpoint =
        "/api/v1/join/events/#{event_user.event_id}/users/#{event_user.user_id}"

      conn = signed_delete(conn, endpoint)
      json = json_response(conn, 200)

      assert json["status"] == "ok"
    end

    test "returns 404 when event_user is not found", %{conn: conn} do
      endpoint =
        "/api/v1/join/events/00000000-0000-0000-0000-000000000000/users/00000000-0000-0000-0000-000000000000"

      conn = signed_delete(conn, endpoint)
      json = json_response(conn, 404)

      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end
end
