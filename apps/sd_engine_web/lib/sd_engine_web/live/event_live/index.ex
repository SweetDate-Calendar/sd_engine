defmodule CLPWeb.EventLive.Index do
  use CLPWeb, :live_view

  alias SD.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Events
        <:actions>
          <.button variant="primary" navigate={~p"/events/new"}>
            <.icon name="hero-plus" /> New Event
          </.button>
        </:actions>
      </.header>

      <.table
        id="events"
        rows={@streams.events}
        row_click={fn {_id, event} -> JS.navigate(~p"/events/#{event}") end}
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
            <.link navigate={~p"/events/#{event}"}>Show</.link>
          </div>
          <.link navigate={~p"/events/#{event}/edit"}>Edit</.link>
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
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Events")
     |> stream(:events, Events.list_events())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event(id)
    {:ok, _} = Events.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end
end
