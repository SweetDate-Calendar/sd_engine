defmodule SDWeb.EventUserEditLive.FormTest do
  use SDWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  import SD.CalendarsFixtures

  describe "EventUserEditLive.Form" do
    setup [:log_in_admin]

    test "renders edit form with event and user info", %{conn: conn} do
      event_user =
        event_user_fixture(%{role: "attendee", status: "invited"})
        |> SD.Repo.preload([:event, :user])

      event = event_user.event
      user = event_user.user

      {:ok, _lv, html} = live(conn, ~p"/events/#{event.id}/users/#{user.id}/edit")

      assert html =~ "Edit Event User"
      assert html =~ user.name
      assert html =~ user.email
    end

    test "updates role and status successfully and redirects", %{conn: conn} do
      event_user =
        event_user_fixture(%{role: "attendee", status: "invited"})
        |> SD.Repo.preload([:event, :user])

      event = event_user.event
      user = event_user.user

      {:ok, lv, _html} = live(conn, ~p"/events/#{event.id}/users/#{user.id}/edit")

      form =
        form(lv, "#event-user-edit-form", %{
          "event_user" => %{"role" => "organizer", "status" => "accepted"}
        })

      # Submit (this triggers push_navigate)
      render_submit(form)

      # Assert redirect happened
      assert_redirect(lv, ~p"/events/#{event.id}/users")

      # Ensure DB was updated
      event_user = SD.Repo.reload!(event_user)
      assert event_user.role == :organizer
      assert event_user.status == :accepted
    end
  end
end
