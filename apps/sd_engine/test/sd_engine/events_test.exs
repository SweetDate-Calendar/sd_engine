defmodule SD.EventsTest do
  alias SD.CalendarsFixtures
  use SD.DataCase

  alias SD.Events

  describe "events" do
    alias SD.Events.Event

    import SD.EventsFixtures

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
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      calendar = CalendarsFixtures.calendar_fixture()

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

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
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
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
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

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
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
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      refute Events.get_event(event.id)
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
