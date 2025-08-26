defmodule SDWeb.EventLive.Index do
  use SDWeb, :live_view

  alias SD.SweetDate

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} >
      <.header>
        Events
        <:subtitle>All events for this calendar</:subtitle>
        <:actions>
          <.button variant="primary" navigate={~p"/calendars/#{@calendar}/events/new"}>
            <.icon name="hero-plus" /> New Event
          </.button>
        </:actions>
      </.header>

      <.table
        id="events"
        rows={@streams.events}
        row_click={fn {_id, event} -> JS.navigate(~p"/calendars/#{@calendar}/events/#{event}") end}
      >
        <:col :let={{_id, event}} label="Name">{event.name}</:col>
        <:col :let={{_id, event}} label="Start">{event.start_time}</:col>
        <:col :let={{_id, event}} label="End">{event.end_time}</:col>
        <:col :let={{_id, event}} label="Status">{event.status}</:col>
        <:col :let={{_id, event}} label="Visibility">{event.visibility}</:col>
        <:action :let={{_id, event}}>
          <div class="sr-only">
            <.link navigate={~p"/calendars/#{@calendar}/events/#{event}"}>Show</.link>
          </div>
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
  def mount(%{"calendar_id" => calendar_id}, _session, socket) do
    events = SweetDate.list_events(calendar_id)

    {:ok,
     socket
     |> assign(:page_title, "Events")
     |> assign(:calendar, calendar_id)
     |> stream(:events, events)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = SweetDate.get_event(id)
    {:ok, _} = SweetDate.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end
end
