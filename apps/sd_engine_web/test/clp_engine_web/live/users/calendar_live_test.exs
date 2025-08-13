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

  describe "Show" do
    setup [:create_calendar, :log_in_admin]

    test "displays calendar", %{conn: conn, user: user, calendar: calendar} do
      {:ok, _show_live, html} =
        live(conn, ~p"/users/#{user.id}/calendars/#{calendar}")

      assert html =~ "Show Calendar"
      assert html =~ user.name
    end
  end
end
