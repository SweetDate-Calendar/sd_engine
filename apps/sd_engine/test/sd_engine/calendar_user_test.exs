defmodule SD.Calendars.CalendarUserTest do
  use SD.DataCase, async: true

  alias SD.Calendars.CalendarUser
  alias SD.Calendars
  alias SD.Repo

  import SD.CalendarsFixtures
  import SD.AccountsFixtures

  describe "calendar_users join" do
    test "user can be added to calendar two times" do
      user = user_fixture()
      calendar = calendar_fixture()

      Calendars.create_calendar_user(%{
        calendar_id: calendar.id,
        user_id: user.id,
        role: :guest
      })

      assert {:error, _} =
               Calendars.create_calendar_user(%{
                 calendar_id: calendar.id,
                 user_id: user.id,
                 role: :guest
               })
    end

    test "user can be added to calendar and accessed from both sides" do
      user = user_fixture()
      calendar = calendar_fixture()

      Calendars.create_calendar_user(%{
        calendar_id: calendar.id,
        user_id: user.id,
        role: :guest
      })

      user = Repo.preload(user, :calendars)
      assert Enum.any?(user.calendars, &(&1.id == calendar.id))

      calendar = Repo.preload(calendar, :users)
      assert Enum.any?(calendar.users, &(&1.id == user.id))
    end

    test "deleting user removes calendar_user row" do
      user = user_fixture()
      calendar = calendar_fixture()

      Calendars.create_calendar_user(%{
        calendar_id: calendar.id,
        user_id: user.id,
        role: :guest
      })

      Repo.delete!(user)

      refute Repo.exists?(
               from(cu in CalendarUser,
                 where: cu.calendar_id == ^calendar.id and cu.user_id == ^user.id
               )
             )
    end

    test "deleting calendar removes calendar_user row" do
      user = user_fixture()
      calendar = calendar_fixture()

      Calendars.create_calendar_user(%{
        calendar_id: calendar.id,
        user_id: user.id,
        role: :guest
      })

      Repo.delete!(calendar)

      refute Repo.exists?(
               from(cu in CalendarUser,
                 where: cu.calendar_id == ^calendar.id and cu.user_id == ^user.id
               )
             )
    end
  end
end
