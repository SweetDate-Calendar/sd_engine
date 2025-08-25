defmodule SD.SweetDateTest do
  use SD.DataCase

  alias SD.SweetDate

  describe "calendars" do
    alias SD.SweetDate.Calendar

    import SD.SweetDateFixtures

    @invalid_attrs %{name: nil, color_theme: nil, visibility: nil}

    test "list_calendars/0 returns all calendars" do
      calendar = calendar_fixture()
      assert SweetDate.list_calendars() == [calendar]
    end

    test "get_calendar/1 returns the calendar with given id" do
      calendar = calendar_fixture()
      assert SweetDate.get_calendar(calendar.id) == calendar
    end

    test "create_calendar/1 with valid data creates a calendar" do
      tenant = SD.TenantsFixtures.tenant_fixture()

      valid_attrs =
        %{
          tenant_id: tenant.id,
          name: "some name",
          color_theme: "some color_theme",
          visibility: :public
        }

      assert {:ok, %Calendar{} = calendar} = SweetDate.create_calendar(valid_attrs)
      assert calendar.name == "some name"
      assert calendar.color_theme == "some color_theme"
      assert calendar.visibility == :public
    end

    test "create_calendar/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SweetDate.create_calendar(@invalid_attrs)
    end

    test "update_calendar/2 with valid data updates the calendar" do
      calendar = calendar_fixture()

      update_attrs = %{
        name: "some updated name",
        color_theme: "some updated color_theme",
        visibility: :private
      }

      assert {:ok, %Calendar{} = calendar} = SweetDate.update_calendar(calendar, update_attrs)
      assert calendar.name == "some updated name"
      assert calendar.color_theme == "some updated color_theme"
      assert calendar.visibility == :private
    end

    test "update_calendar/2 with invalid data returns error changeset" do
      calendar = calendar_fixture()
      assert {:error, %Ecto.Changeset{}} = SweetDate.update_calendar(calendar, @invalid_attrs)
      assert calendar == SweetDate.get_calendar(calendar.id)
    end

    test "delete_calendar/1 deletes the calendar" do
      calendar = calendar_fixture()
      assert {:ok, %Calendar{}} = SweetDate.delete_calendar(calendar)
      refute SweetDate.get_calendar(calendar.id)
    end

    test "change_calendar/1 returns a calendar changeset" do
      calendar = calendar_fixture()
      assert %Ecto.Changeset{} = SweetDate.change_calendar(calendar)
    end
  end
end
