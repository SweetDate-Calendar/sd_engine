defmodule SDWeb.CalendarLive.Show do
  use SDWeb, :live_view

  alias SD.SweetDate

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
          <.button variant="primary" navigate={~p"/calendars/#{@calendar}/edit"}>
            <.icon name="hero-pencil-square" /> Edit calendar
          </.button>
          <.button variant="primary" navigate={~p"/calendars/#{@calendar}/events"}>
            <.icon name="hero-list-bullet" /> Events
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
    # if connected?(socket) do
    #   SweetDate.subscribe_calendars()
    # end

    {:ok,
     socket
     |> assign(:page_title, "Show Calendar")
     |> assign(:calendar, SweetDate.get_calendar(id))}
  end

  @impl true
  def handle_info(
        {:updated, %SD.SweetDate.Calendar{id: id} = calendar},
        %{assigns: %{calendar: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :calendar, calendar)}
  end

  def handle_info(
        {:deleted, %SD.SweetDate.Calendar{id: id}},
        %{assigns: %{calendar: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current calendar was deleted.")
     |> push_navigate(to: ~p"/calendars")}
  end

  def handle_info({type, %SD.SweetDate.Calendar{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
