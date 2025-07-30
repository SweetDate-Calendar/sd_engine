defmodule SDWeb.EventLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.EventsFixtures

  # @create_attrs %{
  #   status: :scheduled,
  #   name: "some name",
  #   description: "some description",
  #   location: "some location",
  #   color_theme: "some color_theme",
  #   visibility: :public,
  #   start_time: "2025-06-09T17:09:00Z",
  #   end_time: "2025-06-09T17:09:00Z",
  #   recurrence_rule: :none,
  #   all_day: true
  # }
  @update_attrs %{
    status: :completed,
    name: "some updated name",
    description: "some updated description",
    location: "some updated location",
    color_theme: "some updated color_theme",
    visibility: :private,
    start_time: "2025-06-10T17:09:00Z",
    end_time: "2025-06-10T17:09:00Z",
    recurrence_rule: :monthly,
    all_day: false
  }
  @invalid_attrs %{
    status: nil,
    name: nil,
    description: nil,
    location: nil,
    color_theme: nil,
    visibility: nil,
    start_time: nil,
    end_time: nil,
    recurrence_rule: nil,
    all_day: false
  }
  defp create_event(_) do
    event = event_fixture()

    %{event: event}
  end

  # describe "Index" do
  #   setup [:create_event, :log_in_admin]

  #   test "lists all events", %{conn: conn, event: event} do
  #     {:ok, _index_live, html} = live(conn, ~p"/events")

  #     assert html =~ "Listing Events"
  #     assert html =~ event.name
  #   end

  #   test "saves new event", %{conn: conn} do
  #     {:ok, index_live, _html} = live(conn, ~p"/events")

  #     assert {:ok, form_live, _} =
  #              index_live
  #              |> element("a", "New Event")
  #              |> render_click()
  #              |> follow_redirect(conn, ~p"/events/new")

  #     assert render(form_live) =~ "New Event"

  #     assert form_live
  #            |> form("#event-form", event: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert {:ok, index_live, _html} =
  #              form_live
  #              |> form("#event-form", event: @create_attrs)
  #              |> render_submit()
  #              |> follow_redirect(conn, ~p"/events")

  #     html = render(index_live)
  #     assert html =~ "Event created successfully"
  #     assert html =~ "some name"
  #   end

  #   test "updates event in listing", %{conn: conn, event: event} do
  #     {:ok, index_live, _html} = live(conn, ~p"/events")

  #     assert {:ok, form_live, _html} =
  #              index_live
  #              |> element("#events-#{event.id} a", "Edit")
  #              |> render_click()
  #              |> follow_redirect(conn, ~p"/events/#{event}/edit")

  #     assert render(form_live) =~ "Edit Event"

  #     assert form_live
  #            |> form("#event-form", event: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert {:ok, index_live, _html} =
  #              form_live
  #              |> form("#event-form", event: @update_attrs)
  #              |> render_submit()
  #              |> follow_redirect(conn, ~p"/events")

  #     html = render(index_live)
  #     assert html =~ "Event updated successfully"
  #     assert html =~ "some updated name"
  #   end

  #   test "deletes event in listing", %{conn: conn, event: event} do
  #     {:ok, index_live, _html} = live(conn, ~p"/events")

  #     assert index_live |> element("#events-#{event.id} a", "Delete") |> render_click()
  #     refute has_element?(index_live, "#events-#{event.id}")
  #   end
  # end

  describe "Show" do
    setup [:create_event, :log_in_admin]

    test "displays event", %{conn: conn, event: event} do
      {:ok, _show_live, html} =
        live(conn, ~p"/calendars/#{event.calendar_id}/events/#{event}?return_to=some-calendar")

      assert html =~ "Event ID: #{event.id}"
    end

    test "updates event and returns to show", %{conn: conn, event: event} do
      {:ok, show_live, _html} =
        live(conn, ~p"/calendars/#{event.calendar_id}/events/#{event}?return_to=some-calendar")

      return_to =
        "http://www.example.com/calendars/#{event.calendar_id}/events/#{event.id}?return_to=some-calendar"
        |> URI.encode()

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/calendars/#{event.calendar_id}/events/#{event}/edit?return_to=#{return_to}"
               )

      assert render(form_live) =~ "Edit Event"

      assert form_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#event-form", event: @update_attrs)
               |> render_submit()
               |> follow_redirect(
                 conn,
                 ~p"/calendars/#{event.calendar_id}/events/#{event}?return_to=some-calendar"
               )

      html = render(show_live)
      assert html =~ "Event updated successfully"
      assert html =~ "some updated name"
    end
  end
end
