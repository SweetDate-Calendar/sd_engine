defmodule SDWeb.Tenants.CalendarLive.Show do
  use SDWeb, :live_view

  alias SD.Calendars

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Calendar ID: {@calendar.id}
        <:actions>
          <.button navigate={~p"/tenants/#{@tenant_id}"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/tenants/#{@tenant_id}/calendars/#{@calendar}/edit?return_to=show_calendar"}
          >
            <.icon name="hero-pencil-square" /> Edit calendar
          </.button>

          <.button
            variant="primary"
            navigate={~p"/calendars/#{@calendar}/events/new?return_to=show_calendar"}
          >
            <.icon name="hero-plus" /> New event
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@calendar.name}</:item>
        <:item title="Color theme">{@calendar.color_theme}</:item>
        <:item title="Visibility">{@calendar.visibility}</:item>
      </.list>
      Events
      <.table
        id="events"
        rows={@streams.events}
        row_click={
          fn {_id, event} ->
            JS.navigate(~p"/calendars/#{@calendar.id}/events/#{event.id}?return_to=show_calendar")
          end
        }
      >
        <:col :let={{_id, event}} label="Name">{event.name}</:col>
        <:col :let={{_id, event}} label="Description">{event.description}</:col>
        <:col :let={{_id, event}} label="Color theme">{event.color_theme}</:col>
        <:col :let={{_id, event}} label="Visibility">{event.visibility}</:col>
        <:col :let={{_id, event}} label="Location">{event.location}</:col>
        <:col :let={{_id, event}} label="Start time">{event.start_time}</:col>
        <:col :let={{_id, event}} label="End time">{event.end_time}</:col>
        <:col :let={{_id, event}} label="Recurrence rule">{event.recurrence_rule}</:col>
        <:col :let={{_id, event}} label="All day">{event.all_day}</:col>
        <:action :let={{_id, event}}>
          <div class="sr-only">
            <.link navigate={
              ~p"/calendars/#{@calendar}/events/#{event}?return_to=#show_tenant_calendar"
            }>
              Show
            </.link>
          </div>
          <.link navigate={
            ~p"/calendars/#{@calendar}/events/#{event}/edit?return_to=show_tenant_calendar"
          }>
            Edit
          </.link>
        </:action>
        <:action :let={{id, event}}>
          <.link
            phx-click={JS.push("delete", value: %{id: event.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"tenant_id" => tenant_id, "id" => id}, _session, socket) do
    calendar = Calendars.get_calendar(id) |> SD.Repo.preload([:events, :tenants])

    {:ok,
     socket
     |> assign(:page_title, "Show Calendar")
     |> assign(:calendar_path, calendar_path)
     |> assign(:tenant_id, tenant_id)
     |> stream(:events, calendar.events)
     |> assign(:calendar, calendar)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = SD.Events.get_event(id)
    {:ok, _} = SD.Events.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end
end
