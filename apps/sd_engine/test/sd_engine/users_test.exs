defmodule SD.UsersTest do
  use SD.DataCase

  alias SD.Users
  alias SD.{Users, Calendars}
  alias SD.Calendars.Calendar
  alias SD.Calendars.CalendarUser

  import SD.UsersFixtures

  describe "add_calendar/2" do
    test "creates a calendar and associates it with the user" do
      # Create a user using your fixture or factory
      user = user_fixture()

      # Params for the new calendar
      params = %{
        name: "Personal Calendar",
        color_theme: "green",
        visibility: "public"
      }

      Users.add_calendar(user.id, params) |> IO.inspect()

      assert {:ok, %{calendar: %Calendar{} = calendar, user_calendar: %CalendarUser{} = cu}} =
               Users.add_calendar(user.id, params)

      db_calendar = Calendars.get_calendar(calendar.id)
      assert db_calendar.name == "Personal Calendar"

      assert cu.user_id == user.id
      assert cu.calendar_id == calendar.id
    end

    test "returns an error when calendar params are invalid" do
      user = user_fixture()

      # Missing required fields
      params = %{name: nil}

      assert {:error, :calendar, %Ecto.Changeset{}, _changes_so_far} =
               Users.add_calendar(user.id, params)
    end
  end

  describe "users" do
    alias SD.Users.User

    @invalid_attrs %{name: nil, email: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      results = Users.list_users()

      assert Enum.any?(results, fn u ->
               u.id == user.id and u.name == user.name and u.email == user.email
             end)
    end

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "John Doe", email: "john@example.com"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.name == "John Doe"
      assert user.email == "john@example.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "Updated Name"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.name == "Updated Name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      refute Users.get_user(user.id)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
