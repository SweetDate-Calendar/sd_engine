defmodule SD.EventsTest do
  alias SD.SweetDateFixtures
  use SD.DataCase

  alias SD.SweetDate

  describe "events" do
    alias SD.Calendars.Event

    import SD.SweetDateFixtures

    @invalid_attrs %{
      name: nil,
      description: nil,
      location: nil,
      color_theme: nil,
      visibility: nil,
      start_time: nil,
      end_time: nil,
      recurrence_rule: nil,
      all_day: nil
    }

    test "list_events/0 returns all events" do
      calendar = calendar_fixture()
      event = event_fixture(%{calendar_id: calendar.id})
      assert SweetDate.list_events(calendar.id) == [event]
    end

    test "list_events/2 returns all events ordered by start_time and respects pagination" do
      calendar = calendar_fixture()

      # Create 3 events with increasing start_time
      e1 = event_fixture(%{calendar_id: calendar.id, start_time: ~U[2025-01-01 12:00:00Z]})
      e2 = event_fixture(%{calendar_id: calendar.id, start_time: ~U[2025-02-01 12:00:00Z]})
      e3 = event_fixture(%{calendar_id: calendar.id, start_time: ~U[2025-03-01 12:00:00Z]})

      # Without pagination — expect all
      assert SweetDate.list_events(calendar.id) == [e1, e2, e3]

      # Limit: 2, Offset: 0 — expect first 2 (e1 and e2)
      assert SweetDate.list_events(calendar.id, limit: 2, offset: 0) == [e1, e2]

      # Limit: 2, Offset: 1 — expect middle and last (e2 and e3)
      assert SweetDate.list_events(calendar.id, limit: 2, offset: 1) == [e2, e3]

      # Limit: 1, Offset: 2 — expect only the last (e3)
      assert SweetDate.list_events(calendar.id, limit: 1, offset: 2) == [e3]
    end

    test "get_event/1 returns the event with given id" do
      event = event_fixture()
      assert SweetDate.get_event(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      calendar = SweetDateFixtures.calendar_fixture()

      valid_attrs = %{
        name: "some name",
        status: :scheduled,
        description: "some description",
        location: "some location",
        color_theme: "some color_theme",
        visibility: :private,
        start_time: ~U[2025-06-09 17:09:00Z],
        end_time: ~U[2025-06-09 17:09:00Z],
        recurrence_rule: :monthly,
        all_day: true,
        calendar_id: calendar.id
      }

      assert {:ok, %Event{} = event} = SweetDate.create_event(valid_attrs)
      assert event.name == "some name"
      assert event.description == "some description"
      assert event.location == "some location"
      assert event.color_theme == "some color_theme"
      assert event.visibility == :private
      assert event.start_time == ~U[2025-06-09 17:09:00Z]
      assert event.end_time == ~U[2025-06-09 17:09:00Z]
      assert event.recurrence_rule == :monthly
      assert event.all_day == true
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SweetDate.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
        name: "some updated name",
        status: :cancelled,
        description: "some updated description",
        location: "some updated location",
        color_theme: "some updated color_theme",
        visibility: :busy,
        start_time: ~U[2025-06-10 17:09:00Z],
        end_time: ~U[2025-06-10 17:09:00Z],
        recurrence_rule: :weekly,
        all_day: false
      }

      assert {:ok, %Event{} = event} = SweetDate.update_event(event, update_attrs)
      assert event.name == "some updated name"
      assert event.status == :cancelled
      assert event.description == "some updated description"
      assert event.location == "some updated location"
      assert event.color_theme == "some updated color_theme"
      assert event.visibility == :busy
      assert event.start_time == ~U[2025-06-10 17:09:00Z]
      assert event.end_time == ~U[2025-06-10 17:09:00Z]
      assert event.recurrence_rule == :weekly
      assert event.all_day == false
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = SweetDate.update_event(event, @invalid_attrs)
      assert event == SweetDate.get_event(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = SweetDate.delete_event(event)
      refute SweetDate.get_event(event.id)
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = SweetDate.change_event(event)
    end
  end
end
