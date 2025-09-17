defmodule SDWeb.EventLive.FormTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.CalendarsFixtures
  import SDWeb.Test.DateHelpers

  @invalid_attrs %{
    name: nil,
    start_time: nil,
    end_time: nil
  }

  describe "new event form" do
    setup [:log_in_admin]

    test "renders error changeset on invalid create", %{conn: conn} do
      calendar = calendar_fixture()

      {:ok, form_live, html} =
        live(conn, ~p"/calendars/#{calendar}/events/new")

      assert html =~ "New Event"

      html =
        form_live
        |> form("#event-form", event: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      assert html =~ "New Event"
    end

    test "renders and creates event", %{conn: conn} do
      calendar = calendar_fixture()

      {:ok, form_live, html} =
        live(conn, ~p"/calendars/#{calendar.id}/events/new")

      assert html =~ "New Event"

      assert form_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {start_s, end_s} = local_window_minutes()

      valid_attrs = %{
        name: "My Event",
        description: "Some description",
        status: "scheduled",
        color_theme: "blue",
        visibility: "public",
        location: "Lystrup",
        start_time: start_s,
        end_time: end_s,
        recurrence_rule: "none",
        all_day: "false",
        calendar_id: calendar.id
      }

      assert {:ok, _live, html} =
               form_live
               |> form("#event-form", event: valid_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/calendars/#{calendar.id}/events")

      assert html =~ "Event created successfully"
      assert html =~ "My Event"
    end
  end

  describe "edit event form" do
    setup [:log_in_admin]

    test "renders error changeset on invalid update", %{conn: conn} do
      event = event_fixture()

      {:ok, form_live, html} =
        live(conn, ~p"/calendars/#{event.calendar_id}/events/#{event}/edit")

      assert html =~ "Edit Event"

      html =
        form_live
        |> form("#event-form", event: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      assert html =~ "Edit Event"
    end

    test "renders and updates event", %{conn: conn} do
      event = event_fixture()

      {:ok, form_live, html} =
        live(conn, ~p"/calendars/#{event.calendar_id}/events/#{event}/edit")

      assert html =~ "Edit Event"

      assert form_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {start_s, end_s} = local_window_minutes()

      update_attrs = %{
        name: "Updated Event",
        description: "Updated description",
        start_time: start_s,
        end_time: end_s
      }

      assert {:ok, _live, html} =
               form_live
               |> form("#event-form", event: update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/calendars/#{event.calendar_id}/events")

      assert html =~ "Event updated successfully"
      assert html =~ "Updated Event"

      # confirm persisted in DB
      updated = SD.SweetDate.get_event(event.id)
      assert updated.name == "Updated Event"
      assert updated.description == "Updated description"
    end
  end

  describe "return_to helper" do
    setup [:log_in_admin]

    test "edit event with return_to=show uses show return path", %{conn: conn} do
      event = event_fixture()

      {:ok, _form_live, html} =
        live(conn, ~p"/calendars/#{event.calendar_id}/events/#{event}/edit?return_to=show")

      assert html =~ "Edit Event"
      assert html =~ "/calendars/#{event.calendar_id}/events/#{event.id}"
    end
  end
end
