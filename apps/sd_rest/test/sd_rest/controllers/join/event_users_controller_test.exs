defmodule SDRest.Join.EventUsersControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  alias SD.Calendars
  alias SD.CalendarsFixtures
  alias SD.AccountsFixtures

  @endpoint "/api/v1/join/calendar_event_users"

  describe "POST /calendar_event_users" do
    test "creates a calendar_event_user join", %{conn: conn} do
      calendar = CalendarsFixtures.calendar_fixture()
      user = AccountsFixtures.user_fixture()
      event = CalendarsFixtures.event_fixture(%{calendar_id: calendar.id})

      body = %{
        "event_id" => event.id,
        "user_id" => user.id,
        "role" => "attendee"
      }

      conn = signed_post(conn, @endpoint, body)

      json = json_response(conn, 201)
      assert json["status"] == "ok"

      join = json["calendar_event_user"]
      assert join["user_id"] == user.id
      assert join["event_id"] == event.id
      assert join["role"] == "attendee"
    end

    test "returns 422 on missing fields", %{conn: conn} do
      conn = signed_post(conn, @endpoint, %{})
      json = json_response(conn, 422)

      assert json["status"] == "error"
      assert json["message"] == "validation failed"
      assert Map.has_key?(json["details"], "user_id")
      assert Map.has_key?(json["details"], "event_id")
    end
  end

  describe "PUT /calendar_event_users/:id" do
    test "updates the role of an existing join", %{conn: conn} do
      calendar = CalendarsFixtures.calendar_fixture()
      user = AccountsFixtures.user_fixture()
      event = CalendarsFixtures.event_fixture(%{calendar_id: calendar.id})

      {:ok, join} =
        Calendars.create_event_user(%{
          "event_id" => event.id,
          "user_id" => user.id,
          "role" => :viewer
        })

      body = %{"role" => "organizer"}

      conn = signed_put(conn, "#{@endpoint}/#{join.id}", body)

      json = json_response(conn, 200)
      assert json["status"] == "ok"
      assert json["calendar_event_user"]["role"] == "organizer"
    end
  end

  describe "DELETE /calendar_event_users/:id" do
    test "deletes an existing join", %{conn: conn} do
      calendar = CalendarsFixtures.calendar_fixture()
      user = AccountsFixtures.user_fixture()
      event = CalendarsFixtures.event_fixture(%{calendar_id: calendar.id})

      {:ok, join} =
        Calendars.create_event_user(%{
          "event_id" => event.id,
          "user_id" => user.id,
          "role" => :attendee
        })

      conn = signed_delete(conn, "#{@endpoint}/#{join.id}")

      json = json_response(conn, 200)
      assert json["status"] == "ok"
      assert json["calendar_event_user"]["id"] == join.id
    end

    test "returns 404 when join does not exist", %{conn: conn} do
      conn = signed_delete(conn, "#{@endpoint}/00000000-0000-0000-0000-000000000000")

      json = json_response(conn, 404)
      assert json["status"] == "error"
      assert json["message"] == "not found"
    end
  end
end
