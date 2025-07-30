defmodule SDWeb.EventLive.Show do
  use SDWeb, :live_view

  alias SD.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Event ID: {@event.id}
        <:actions>
          <.button navigate={@return_back}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={
              ~p"/calendars/#{@event.calendar_id}/events/#{@event.id}/edit?return_to=#{@return_to}"
            }
          >
            <.icon name="hero-pencil-square" /> Edit event
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@event.name}</:item>
        <:item title="Description">{@event.description}</:item>
        <:item title="Color theme">{@event.color_theme}</:item>
        <:item title="Visibility">{@event.visibility}</:item>
        <:item title="Location">{@event.location}</:item>
        <:item title="Start time">{@event.start_time}</:item>
        <:item title="End time">{@event.end_time}</:item>
        <:item title="Recurrence rule">{@event.recurrence_rule}</:item>
        <:item title="All day">{@event.all_day}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true

  def mount(%{"id" => id, "return_to" => return_to}, _session, socket) do
    event = Events.get_event(id) |> SD.Repo.preload(:calendar)

    {:ok,
     socket
     |> assign(:return_back, return_to)
     |> assign(:page_title, "Show Event")
     |> assign(:event, event)}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply, assign(socket, return_to: url)}
  end
end
