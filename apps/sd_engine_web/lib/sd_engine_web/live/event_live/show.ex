defmodule SDWeb.EventLive.Show do
  use SDWeb, :live_view

  alias SD.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Event {@event.id}
        <:actions>
          <.button navigate={@return_to}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={
              ~p"/calendars/#{@event.calendar_id}/events/#{@event}/edit?return_to=#{@return_to}"
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

    IO.inspect(return_to)

    return_to =
      ~p"/calendars/16c0b051-00fe-43ad-a757-490d5d82e258/events/9e5058b1-3b22-4fb1-9b61-cf5b23a8039e?return_to=%2Ftenants%2Fd179f765-a6c4-49de-a4b5-785d0512f269%2Fcalendars%2F16c0b051-00fe-43ad-a757-490d5d82e258%2F"

    {:ok,
     socket
     |> assign(:return_to, return_to)
     |> assign(:page_title, "Show Event")
     |> assign(:event, event)}
  end
end
