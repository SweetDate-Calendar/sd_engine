defmodule CLPWeb.EventLive.Show do
  use CLPWeb, :live_view

  alias SD.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Event {@event.id}
        <:subtitle>This is a event record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/events"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/events/#{@event}/edit?return_to=show"}>
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
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Event")
     |> assign(:event, Events.get_event(id))}
  end
end
