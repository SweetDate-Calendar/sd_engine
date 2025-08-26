defmodule SDWeb.EventLive.Show do
  use SDWeb, :live_view

  alias SD.SweetDate

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Event ID: {@event.id}
        <:actions>
          <.button navigate={~p"/calendars/#{@calendar_id}"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/calendars/#{@calendar_id}/events/#{@event}/edit?return_to=show"}>
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

  def mount(%{"calendar_id" => calendar_id, "id" => id}, _session, socket) do
    event = SweetDate.get_event(id) |> SD.Repo.preload(:calendar)

    {:ok,
     socket
     |> assign(:page_title, "Show Event")
     |> assign(:calendar_id, calendar_id)
     |> assign(:event, event)}
  end

  # @impl true
  # def handle_params(_params, url, socket) do
  #   {:noreply, socket}
  # end
end
