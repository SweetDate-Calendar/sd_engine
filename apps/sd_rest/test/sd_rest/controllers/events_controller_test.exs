defmodule SDRest.EventsControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  import Phoenix.ConnTest
  import SD.SweetDateFixtures

  setup %{conn: conn} do
    calendar = calendar_fixture(%{name: "Main"})

    {:ok, conn: conn, calendar: calendar}
  end

  describe "GET /api/v1/calendars/:calendar_id/events" do
    test "returns events with default pagination", %{conn: conn, calendar: calendar} do
      event_fixture(%{
        calendar_id: calendar.id,
        name: "Alpha",
        start_time: ~U[2025-01-01 00:00:00Z]
      })

      event_fixture(%{
        calendar_id: calendar.id,
        name: "Beta",
        start_time: ~U[2025-01-02 00:00:00Z]
      })

      event_fixture(%{
        calendar_id: calendar.id,
        name: "Gamma",
        start_time: ~U[2025-01-03 00:00:00Z]
      })

      path = "/api/v1/calendars/#{calendar.id}/events"
      conn = signed_get(conn, path)

      %{
        "status" => "ok",
        "result" => %{"events" => events, "limit" => 25, "offset" => 0}
      } = json_response(conn, 200)

      assert Enum.map(events, & &1["name"]) == ["Alpha", "Beta", "Gamma"]
    end

    test "respects pagination params", %{conn: conn, calendar: calendar} do
      event_fixture(%{
        calendar_id: calendar.id,
        name: "One",
        start_time: ~U[2025-01-01 00:00:00Z]
      })

      event_fixture(%{
        calendar_id: calendar.id,
        name: "Two",
        start_time: ~U[2025-01-02 00:00:00Z]
      })

      event_fixture(%{
        calendar_id: calendar.id,
        name: "Three",
        start_time: ~U[2025-01-03 00:00:00Z]
      })

      path = "/api/v1/calendars/#{calendar.id}/events?limit=2&offset=1"
      conn = signed_get(conn, path)

      %{
        "status" => "ok",
        "result" => %{"events" => events, "limit" => 2, "offset" => 1}
      } = json_response(conn, 200)

      assert Enum.map(events, & &1["name"]) == ["Two", "Three"]
    end
  end

  describe "POST /api/v1/calendars/:calendar_id/events" do
    test "creates a new event", %{conn: conn, calendar: calendar} do
      path = "/api/v1/calendars/#{calendar.id}/events"

      payload = %{
        name: "Planning",
        description: "Q3 planning session",
        status: "scheduled",
        visibility: "busy",
        color_theme: "default",
        location: "Zoom",
        start_time: "2025-08-22T13:00:00Z",
        end_time: "2025-08-22T14:00:00Z",
        recurrence_rule: "none",
        all_day: false
      }

      conn = signed_post(conn, path, payload)

      %{"status" => "ok", "event" => event} = json_response(conn, 201)
      assert event["name"] == "Planning"
      assert event["location"] == "Zoom"
    end
  end

  describe "PUT /api/v1/calendars/:calendar_id/events/:id" do
    test "updates an event", %{conn: conn, calendar: calendar} do
      event = event_fixture(%{calendar_id: calendar.id, name: "Before"})
      path = "/api/v1/calendars/#{calendar.id}/events/#{event.id}"

      conn = signed_put(conn, path, %{"name" => "After"})

      %{"status" => "ok", "event" => updated_event} = json_response(conn, 200)
      assert updated_event["name"] == "After"
    end
  end

  describe "DELETE /api/v1/calendars/:calendar_id/events/:id" do
    test "deletes an event", %{conn: conn, calendar: calendar} do
      event = event_fixture(%{calendar_id: calendar.id})
      path = "/api/v1/calendars/#{calendar.id}/events/#{event.id}"

      conn = signed_delete(conn, path)
      %{"status" => "ok", "event" => deleted_event} = json_response(conn, 200)
      assert deleted_event["id"] == event.id

      conn2 = signed_get(build_conn(), path)
      assert json_response(conn2, 404)
    end
  end
end
