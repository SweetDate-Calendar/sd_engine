defmodule CLPWeb.CalendarLive.Show do
  use CLPWeb, :live_view

  alias SD.Calendars

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Calendar {@calendar.id}
        <:subtitle>This is a calendar record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/accounts/#{@calendar.tier.account}/tiers/#{@calendar.tier}"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={
              ~p"/tiers/#{@calendar.tier_id}/calendars/#{@calendar}/edit?return_to=show_calendar"
            }
          >
            <.icon name="hero-pencil-square" /> Edit calendar
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@calendar.name}</:item>
        <:item title="Color theme">{@calendar.color_theme}</:item>
        <:item title="Visibility">{@calendar.visibility}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    calendar = Calendars.get_calendar(id) |> SD.Repo.preload(tier: [:account])

    {:ok,
     socket
     |> assign(:page_title, "Show Calendar")
     |> stream(:events, [])
     |> assign(:calendar, calendar)}
  end
end
