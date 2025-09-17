defmodule SD.CalendarsTest do
  use SD.DataCase, async: true

  alias SD.Calendars
  alias SD.Calendars.{CalendarUser, EventUser}

  import SD.CalendarsFixtures
  import SD.AccountsFixtures

  describe "calendar_users" do
    test "create_calendar_user/1 with valid data" do
      calendar = calendar_fixture()
      user = user_fixture()

      valid_attrs = %{calendar_id: calendar.id, user_id: user.id, role: "owner"}
      assert {:ok, %CalendarUser{} = cu} = Calendars.create_calendar_user(valid_attrs)
      assert cu.role == :owner
    end

    test "create_calendar_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendars.create_calendar_user(%{})
    end

    test "get_calendar_user/2 returns the calendar_user" do
      cu = calendar_user_fixture()
      assert {:ok, found} = Calendars.get_calendar_user(cu.calendar_id, cu.user_id)
      assert found.id == cu.id
      assert found.user.id == cu.user_id
    end

    test "get_calendar_user/2 returns :not_found when missing" do
      u = user_fixture()

      assert {:error, :not_found} =
               Calendars.get_calendar_user(Ecto.UUID.generate(), u.id)
    end

    test "get_calendar_user/2 returns :invalid_calendar_id for bad uuid" do
      u = user_fixture()

      assert {:error, :invalid_calendar_id} =
               Calendars.get_calendar_user("not-a-uuid", u.id)
    end

    test "get_calendar_user/2 returns :invalid_user_id for bad uuid" do
      c = calendar_fixture()

      assert {:error, :invalid_user_id} =
               Calendars.get_calendar_user(c.id, "not-a-uuid")
    end

    test "list_calendar_users/0 returns all calendar_users" do
      cu = calendar_user_fixture()
      assert Enum.any?(Calendars.list_calendar_users(), &(&1.id == cu.id))
    end

    test "update_calendar_user/2 updates role" do
      cu = calendar_user_fixture(%{role: "guest"})

      assert {:ok, %CalendarUser{} = updated} =
               Calendars.update_calendar_user(cu, %{role: "admin"})

      assert updated.role == :admin
    end

    test "update_calendar_user/2 with invalid data returns error" do
      cu = calendar_user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Calendars.update_calendar_user(cu, %{role: nil})
    end

    test "delete_calendar_user/1 deletes the record" do
      cu = calendar_user_fixture()
      assert {:ok, %CalendarUser{}} = Calendars.delete_calendar_user(cu)

      assert {:error, :not_found} =
               Calendars.get_calendar_user(cu.calendar_id, cu.user_id)
    end

    test "change_calendar_user/1 returns a changeset" do
      cu = calendar_user_fixture()
      assert %Ecto.Changeset{} = Calendars.change_calendar_user(cu)
    end
  end

  describe "event_users" do
    test "create_event_user/1 with valid data" do
      event = event_fixture()
      user = user_fixture()

      valid_attrs = %{event_id: event.id, user_id: user.id, role: "attendee", status: "invited"}
      assert {:ok, %EventUser{} = eu} = Calendars.create_event_user(valid_attrs)
      assert eu.role == :attendee
      assert eu.status == :invited
    end

    test "create_event_user/1 with invalid data returns error" do
      assert {:error, %Ecto.Changeset{}} = Calendars.create_event_user(%{})
    end

    test "get_event_user/2 returns the event_user" do
      eu = event_user_fixture()
      assert {:ok, found} = Calendars.get_event_user(eu.event_id, eu.user_id)
      assert found.id == eu.id
      assert found.user.id == eu.user_id
    end

    test "get_event_user/2 returns :not_found when missing" do
      u = user_fixture()

      assert {:error, :not_found} =
               Calendars.get_event_user(Ecto.UUID.generate(), u.id)
    end

    test "get_event_user/2 returns :invalid_event_id for bad uuid" do
      u = user_fixture()

      assert {:error, :invalid_event_id} =
               Calendars.get_event_user("not-a-uuid", u.id)
    end

    test "get_event_user/2 returns :invalid_user_id for bad uuid" do
      e = event_fixture()

      assert {:error, :invalid_user_id} =
               Calendars.get_event_user(e.id, "not-a-uuid")
    end

    test "list_event_users/0 returns all event_users" do
      eu = event_user_fixture()
      assert Enum.any?(Calendars.list_event_users(), &(&1.id == eu.id))
    end

    test "update_event_user/2 updates role and status" do
      eu = event_user_fixture(%{role: "guest", status: "invited"})

      assert {:ok, %EventUser{} = updated} =
               Calendars.update_event_user(eu, %{role: "organizer", status: "accepted"})

      assert updated.role == :organizer
      assert updated.status == :accepted
    end

    test "update_event_user/2 with invalid data returns error" do
      eu = event_user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Calendars.update_event_user(eu, %{role: nil})
    end

    test "delete_event_user/1 deletes the record" do
      eu = event_user_fixture()
      assert {:ok, %EventUser{}} = Calendars.delete_event_user(eu)

      assert {:error, :not_found} =
               Calendars.get_event_user(eu.event_id, eu.user_id)
    end

    test "change_event_user/1 returns a changeset" do
      eu = event_user_fixture()
      assert %Ecto.Changeset{} = Calendars.change_event_user(eu)
    end
  end
end
