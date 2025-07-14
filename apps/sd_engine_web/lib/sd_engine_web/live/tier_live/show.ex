defmodule SDWeb.TierLive.Show do
  use SDWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Tier {@tier.id}
        <:subtitle>This is a tier record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/accounts/#{@tier.account}"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            id={"edit-tier-#{@tier.id}"}
            navigate={~p"/accounts/#{@tier.account}/tiers/#{@tier}/edit?return_to=show_tier"}
          >
            <.icon name="hero-pencil-square" /> Edit tier
          </.button>

          <.button variant="primary" navigate={~p"/tiers/#{@tier}/calendars/new?return_to=show_tier"}>
            <.icon name="hero-plus" /> New Calendar
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@tier.name}</:item>
      </.list>
      Calendars
      <.table
        id="calendars"
        rows={@streams.calendars}
        row_click={
          fn {_id, calendar} -> JS.navigate(~p"/tiers/#{@tier.id}/calendars/#{calendar}") end
        }
      >
        <:col :let={{_id, calendar}} label="Name">{calendar.name}</:col>
        <:col :let={{_id, calendar}} label="Color theme">{calendar.color_theme}</:col>
        <:col :let={{_id, calendar}} label="Visibility">{calendar.visibility}</:col>
        <:action :let={{_id, calendar}}>
          <div class="sr-only">
            <.link navigate={~p"/tiers/#{calendar.tier_id}/calendars/#{calendar}"}>Show</.link>
          </div>
          <.link
            id={"edit-calendar-#{calendar.id}"}
            navigate={~p"/tiers/#{calendar.tier_id}/calendars/#{calendar}/edit?return_to=show_tier"}
          >
            Edit
          </.link>
        </:action>
        <:action :let={{id, calendar}}>
          <.link
            phx-click={
              JS.push("delete_calendar", value: %{calendar_id: calendar.id}) |> hide("##{id}")
            }
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
  def mount(%{"id" => id}, _session, socket) do
    tier = SD.Tiers.get_tier(id) |> SD.Repo.preload([:calendars, :account])

    {:ok,
     socket
     |> assign(:page_title, "Show Tier")
     |> stream(:calendars, tier.calendars)
     |> assign(:tier, tier)}
  end

  @impl true
  def handle_event("delete_calendar", %{"calendar_id" => calendar_id}, socket) do
    calendar = SD.Calendars.get_calendar(calendar_id)
    {:ok, _} = SD.Calendars.delete_calendar(calendar)

    {:noreply, stream_delete(socket, :calendars, calendar)}
  end
end
