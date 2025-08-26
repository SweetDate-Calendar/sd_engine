defmodule SDWeb.CalendarLive.Index do
  use SDWeb, :live_view

  alias SD.SweetDate

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Calendars
        <:actions>
          <.button variant="primary" navigate={~p"/calendars/new"}>
            <.icon name="hero-plus" /> New Calendar
          </.button>
        </:actions>
      </.header>

      <.table
        id="calendars"
        rows={@streams.calendars}
        row_click={fn {_id, calendar} -> JS.navigate(~p"/calendars/#{calendar}") end}
      >
        <:col :let={{_id, calendar}} label="Name">{calendar.name}</:col>
        <:col :let={{_id, calendar}} label="Color theme">{calendar.color_theme}</:col>
        <:col :let={{_id, calendar}} label="Visibility">{calendar.visibility}</:col>

        <:action :let={{_id, calendar}}>
          <div class="sr-only">
            <.link navigate={~p"/calendars/#{calendar}"}>Show</.link>
          </div>
          <.link navigate={~p"/calendars/#{calendar}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, calendar}}>
          <.link
            phx-click={JS.push("delete", value: %{id: calendar.id}) |> hide("##{id}")}
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
    # if connected?(socket) do
    #   SweetDate.subscribe_calendars()
    # end

    {:ok,
     socket
     |> assign(:page_title, "Listing Calendars")
     |> stream(:calendars, SweetDate.list_calendars())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    calendar = SweetDate.get_calendar(id)
    {:ok, _} = SweetDate.delete_calendar(calendar)

    {:noreply, stream_delete(socket, :calendars, calendar)}
  end

  @impl true
  def handle_info({type, %SD.SweetDate.Calendar{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :calendars, SweetDate.list_calendars(), reset: true)}
  end
end
