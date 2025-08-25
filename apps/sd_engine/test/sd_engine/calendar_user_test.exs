defmodule SD.Accounts.CalendarUserTest do
  use SD.DataCase, async: true

  alias SD.Accounts.CalendarUser
  alias SD.Accounts
  alias SD.Repo

  import SD.SweetDateFixtures
  import SD.UsersFixtures

  describe "calendar_users join" do
    test "user can be added to calendar two times" do
      user = user_fixture()
      calendar = calendar_fixture()

      Accounts.create_calendar_user(calendar.id, user.id, :guest)

      assert {:error, _} =
               Accounts.create_calendar_user(calendar.id, user.id, :guest)
    end

    test "user can be added to calendar and accessed from both sides" do
      user = user_fixture()
      calendar = calendar_fixture()

      Accounts.create_calendar_user(calendar.id, user.id, :guest)

      user = Repo.preload(user, :calendars)
      assert Enum.any?(user.calendars, &(&1.id == calendar.id))

      calendar = Repo.preload(calendar, :users)
      assert Enum.any?(calendar.users, &(&1.id == user.id))
    end

    test "deleting user removes calendar_user row" do
      user = user_fixture()
      calendar = calendar_fixture()

      Accounts.create_calendar_user(calendar.id, user.id, :guest)

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

      Accounts.create_calendar_user(calendar.id, user.id, :guest)

      Repo.delete!(calendar)

      refute Repo.exists?(
               from(au in CalendarUser,
                 where: au.calendar_id == ^calendar.id and au.user_id == ^user.id
               )
             )
    end
  end
end
