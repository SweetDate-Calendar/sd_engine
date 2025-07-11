defmodule SDWeb.CalendarLive.Form do
  use SDWeb, :live_view

  alias SD.Calendars
  alias SD.Calendars.Calendar

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage calendar records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="calendar-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:color_theme]} type="text" label="Color theme" />
        <.input field={@form[:visibility]} type="text" label="Visibility" />
        <.input field={@form[:tier_id]} type="text" class="hidden" />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Calendar</.button>
          <.button navigate={return_path(@return_to, @calendar)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"tier_id" => tier_id} = params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:tier_id, tier_id)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show_tier"), do: "show_tier"
  defp return_to(_), do: "show_calendar"

  defp apply_action(socket, :edit, %{"id" => id}) do
    calendar = Calendars.get_calendar(id)

    socket
    |> assign(:page_title, "Edit Calendar")
    |> assign(:calendar, calendar)
    |> assign(:form, to_form(Calendars.change_calendar(calendar)))
  end

  defp apply_action(socket, :new, %{"tier_id" => tier_id}) do
    calendar = %Calendar{tier_id: tier_id}

    socket
    |> assign(:page_title, "New Calendar")
    |> assign(:calendar, calendar)
    |> assign(:form, to_form(Calendars.change_calendar(calendar)))
  end

  @impl true
  def handle_event("validate", %{"calendar" => calendar_params}, socket) do
    changeset = Calendars.change_calendar(socket.assigns.calendar, calendar_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"calendar" => calendar_params}, socket) do
    save_calendar(socket, socket.assigns.live_action, calendar_params)
  end

  defp save_calendar(socket, :edit, calendar_params) do
    case Calendars.update_calendar(socket.assigns.calendar, calendar_params) do
      {:ok, calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, calendar))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_calendar(socket, :new, calendar_params) do
    case Calendars.create_calendar(calendar_params) do
      {:ok, calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, calendar))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("show_tier", calendar) do
    calendar =
      calendar
      |> SD.Repo.preload(:tier)

    ~p"/accounts/#{calendar.tier.account_id}/tiers/#{calendar.tier_id}"
  end

  defp return_path("show_calendar", calendar) do
    ~p"/tiers/#{calendar.tier_id}/calendars/#{calendar}"
  end
end
