defmodule SDWeb.Users.CalendarLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.UsersFixtures

  defp create_calendar(_context) do
    user = user_fixture()

    params = %{
      name: "some name-#{System.unique_integer([:positive])}",
      color_theme: "some color_theme",
      visibility: :public
    }

    {:ok, calendar} = SD.Users.add_calendar(user.id, params)
    calendar = SD.Repo.preload(calendar, :users)

    %{calendar: calendar, user: user}
  end

  describe "User Show - calendar actions" do
    setup [:create_calendar, :log_in_admin]

    test "displays calendar", %{conn: conn, user: user, calendar: calendar} do
      {:ok, _show_live, html} =
        live(conn, ~p"/users/#{user.id}/calendars/#{calendar}")

      assert html =~ "Show Calendar"
      assert html =~ user.name
    end

    test "navigates to edit calendar from user show", %{
      conn: conn,
      user: user,
      calendar: calendar
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/#{user.id}")

      lv
      |> element("#edit-calendar-#{calendar.id}")
      |> render_click()

      assert_redirect(
        lv,
        ~p"/users/#{user.id}/calendars/#{calendar}/edit?return_to=show_user"
      )
    end

    test "deletes calendar from user show", %{conn: conn, user: user, calendar: calendar} do
      {:ok, lv, _html} = live(conn, ~p"/users/#{user.id}")

      # Ensure the row is present
      row_id = "calendars-#{calendar.id}"
      assert has_element?(lv, "##{row_id}")

      # Click the Delete link inside that row
      lv
      |> element("##{row_id} a", "Delete")
      |> render_click()

      # Row is removed from the stream/DOM
      refute has_element?(lv, "##{row_id}")

      # Optional: verify DB deletion
      assert is_nil(SD.Repo.get(SD.Calendars.Calendar, calendar.id))
    end
  end
end
