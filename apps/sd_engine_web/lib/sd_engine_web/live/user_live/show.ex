defmodule SDWeb.UserLive.Show do
  use SDWeb, :live_view

  alias SD.Users

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        User ID: {@user.id}
        <:actions>
          <.button navigate={~p"/users"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/users/#{@user}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit user
          </.button>
          <.button variant="primary" navigate={~p"/users/#{@user}/calendars/new?return_to=show_user"}>
            <.icon name="hero-plus" /> New Calendar
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@user.name}</:item>
        <:item title="Email">{@user.email}</:item>
      </.list>
      Calendars
      <.table
        id="calendars"
        rows={@streams.calendars}
        row_click={
          fn {_id, calendar} -> JS.navigate(~p"/users/#{@user.id}/calendars/#{calendar}") end
        }
      >
        <:col :let={{_id, calendar}} label="Name">{calendar.name}</:col>
        <:col :let={{_id, calendar}} label="Color theme">{calendar.color_theme}</:col>
        <:col :let={{_id, calendar}} label="Visibility">{calendar.visibility}</:col>
        <:action :let={{_id, calendar}}>
          <div class="sr-only">
            <.link navigate={~p"/users/#{@user.id}/calendars/#{calendar}"}>Show</.link>
          </div>
          <.link
            id={"edit-calendar-#{calendar.id}"}
            navigate={~p"/users/#{@user.id}/calendars/#{calendar}/edit?return_to=show_user"}
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
    user =
      Users.get_user(id)
      |> SD.Repo.preload([:calendars])

    {:ok,
     socket
     |> assign(:page_title, "Show User")
     |> stream(:calendars, user.calendars)
     |> assign(:user, user)}
  end

  @impl true
  def handle_event("delete_calendar", %{"calendar_id" => calendar_id}, socket) do
    calendar = SD.Calendars.get_calendar(calendar_id)
    {:ok, _} = SD.Calendars.delete_calendar(calendar)

    {:noreply, stream_delete(socket, :calendars, calendar)}
  end
end
