defmodule SDWeb.InvitationLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.NotificationsFixtures
  import SD.CalendarsFixtures
  # import SD.CredentialsFixtures

  @create_attrs %{
    status: "pending",
    token: "some token",
    role: "organizer",
    expires_at: "2025-08-26T11:15:00Z"
  }
  @update_attrs %{
    status: "accepted",
    token: "some updated token",
    role: "attendee",
    expires_at: "2025-08-27T11:15:00Z"
  }
  @invalid_attrs %{status: nil, token: nil, role: nil, expires_at: nil}
  defp create_invitation(_) do
    event = event_fixture()
    invitation = invitation_fixture(%{event: event})

    %{invitation: invitation, event: event}
  end

  describe "Index" do
    setup [:create_invitation, :log_in_admin]

    test "lists all event_invitations", %{conn: conn, event: event, invitation: invitation} do
      {:ok, _index_live, html} = live(conn, ~p"/events/#{event}/event_invitations")

      assert html =~ "Listing Event invitations"
      assert html =~ Atom.to_string(invitation.status)
    end

    test "saves new invitation", %{conn: conn, event: event} do
      {:ok, index_live, _html} = live(conn, ~p"/events/#{event.id}/event_invitations")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Invitation")
               |> render_click()
               |> follow_redirect(conn, ~p"/events/#{event.id}/event_invitations/new")

      assert render(form_live) =~ "New Invitation"

      assert form_live
             |> form("#invitation-form", invitation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#invitation-form", invitation: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/events/#{event.id}/event_invitations")

      html = render(index_live)
      assert html =~ "Invitation created successfully"
      assert html =~ "organizer"
    end

    test "updates invitation in listing", %{conn: conn, event: event, invitation: invitation} do
      {:ok, index_live, _html} = live(conn, ~p"/events/#{event.id}/event_invitations")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#event_invitations-#{invitation.id} a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/events/#{event.id}/event_invitations/#{invitation}/edit"
               )

      assert render(form_live) =~ "Edit Invitation"

      assert form_live
             |> form("#invitation-form", invitation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#invitation-form", invitation: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/events/#{invitation.event_id}/event_invitations")

      html = render(index_live)
      assert html =~ "Invitation updated successfully"
      assert html =~ "attendee"
    end

    test "deletes invitation in listing", %{conn: conn, event: event, invitation: invitation} do
      {:ok, index_live, _html} = live(conn, ~p"/events/#{event}/event_invitations")

      assert index_live
             |> element("#event_invitations-#{invitation.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#event_invitations-#{invitation.id}")
    end
  end

  describe "Show" do
    setup [:create_invitation, :log_in_admin]

    test "displays invitation", %{conn: conn, event: event, invitation: invitation} do
      {:ok, _show_live, html} =
        live(conn, ~p"/events/#{event.id}/event_invitations/#{invitation}")

      assert html =~ "Show Invitation"
      assert html =~ Atom.to_string(invitation.status)
    end

    test "updates invitation and returns to show", %{conn: conn, invitation: invitation} do
      {:ok, show_live, _html} =
        live(conn, ~p"/events/#{invitation.event_id}/event_invitations/#{invitation}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/events/#{invitation.event_id}/event_invitations/#{invitation}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Invitation"

      assert form_live
             |> form("#invitation-form", invitation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#invitation-form", invitation: @update_attrs)
               |> render_submit()
               |> follow_redirect(
                 conn,
                 ~p"/events/#{invitation.event_id}/event_invitations/#{invitation}"
               )

      html = render(show_live)
      assert html =~ "Invitation updated successfully"
      assert html =~ "accepted"
    end
  end
end
