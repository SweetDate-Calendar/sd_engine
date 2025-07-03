defmodule CLPWeb.CalendarLive.Show do
  use CLPWeb, :live_view

  alias CLP.Calendars

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Calendar {@calendar.id}
        <:subtitle>This is a calendar record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/calendars"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/tiers/#{@calendar.tier}/#{@calendar}/edit?return_to=show"}
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
    {:ok,
     socket
     |> assign(:page_title, "Show Calendar")
     |> assign(:calendar, Calendars.get_calendar(id))
     |> CLP.Repo.preload(:tier)}
  end
end
