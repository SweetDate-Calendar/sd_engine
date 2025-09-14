defmodule SDWeb.EventUserLive.FormTest do
  use SDWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  import SD.AccountsFixtures
  import SD.CalendarsFixtures

  describe "EventUserLive.Form" do
    setup [:log_in_admin]

    test "mounts and shows event info", %{conn: conn} do
      event = event_fixture()
      {:ok, _lv, html} = live(conn, ~p"/events/#{event.id}/users")

      assert html =~ "Event Users"
      assert html =~ event.name
    end

    test "assigns a user to event", %{conn: conn} do
      event = event_fixture()
      user = user_fixture()

      {:ok, lv, _html} = live(conn, ~p"/events/#{event.id}/users")

      form =
        form(lv, "#event-user-form", %{
          "event_user" => %{
            "user_id" => user.id,
            "role" => "organizer",
            "status" => "accepted"
          }
        })

      result = render_submit(form)

      assert result =~ "User assigned to event successfully"
      assert result =~ user.name
      assert result =~ "organizer"
      assert result =~ "accepted"
    end

    test "shows error when user already assigned", %{conn: conn} do
      event = event_fixture()
      user = user_fixture()

      # first assignment succeeds
      {:ok, lv, _} = live(conn, ~p"/events/#{event.id}/users")

      render_submit(
        form(lv, "#event-user-form", %{
          "event_user" => %{"user_id" => user.id, "role" => "attendee", "status" => "invited"}
        })
      )

      # second assignment triggers unique constraint
      {:ok, lv, _} = live(conn, ~p"/events/#{event.id}/users")

      result =
        render_submit(
          form(lv, "#event-user-form", %{
            "event_user" => %{"user_id" => user.id, "role" => "attendee", "status" => "invited"}
          })
        )

      assert result =~ "This user is already assigned to the event"
    end

    test "removes an assigned user", %{conn: conn} do
      event = event_fixture()
      user = user_fixture()

      {:ok, lv, _} = live(conn, ~p"/events/#{event.id}/users")

      render_submit(
        form(lv, "#event-user-form", %{
          "event_user" => %{"user_id" => user.id, "role" => "guest", "status" => "maybe"}
        })
      )

      # re-mount to show table with assigned user
      {:ok, lv, _} = live(conn, ~p"/events/#{event.id}/users")

      # click the Remove link
      result = render_click(element(lv, "a", "Remove"))

      assert result =~ "User removed from event successfully"
      refute render(lv) =~ ~s(id="event-user-name-#{user.id}")
    end
  end
end
