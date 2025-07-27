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
      </.header>

      <.form for={@form} id="calendar-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:color_theme]} type="text" label="Color theme" />
        <.input field={@form[:visibility]} type="text" label="Visibility" />
        <.input field={@form[:tenant_id]} class="hidden" value={@calendar.tenant_id} />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Calendar</.button>
          <.button navigate={return_path(@return_to, @return_to_id)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"tenant_id" => tenant_id} = params, _session, socket) do
    {:ok,
     socket
     |> assign(return_to_id: return_to_id(params))
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:tenant_id, tenant_id)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to_id(params) do
    case params["return_to"] do
      "show_calendar" ->
        params["id"]

      _ ->
        params["tenant_id"]
    end
  end

  # Normalize return_to flag
  defp return_to("show_tenant"), do: "show_tenant"
  defp return_to(_), do: "show_calendar"

  # Edit mode: load an existing calendar
  defp apply_action(socket, :edit, %{"id" => id}) do
    calendar = Calendars.get_calendar(id)

    socket
    |> assign(:page_title, "Edit Calendar")
    |> assign(:calendar, calendar)
    |> assign(:form, to_form(Calendars.change_calendar(calendar)))
  end

  # New mode: prepare a blank calendar struct with tenant_id
  defp apply_action(socket, :new, %{"tenant_id" => tenant_id}) do
    calendar = %Calendar{tenant_id: tenant_id}

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

  @impl true
  def handle_event("save", %{"calendar" => calendar_params}, socket) do
    save_calendar(socket, socket.assigns.live_action, calendar_params)
  end

  # Save updates
  defp save_calendar(socket, :edit, calendar_params) do
    case Calendars.update_calendar(socket.assigns.calendar, calendar_params) do
      {:ok, _calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, socket.assigns.return_to_id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # Save new
  defp save_calendar(socket, :new, calendar_params) do
    case Calendars.create_calendar(calendar_params) do
      {:ok, calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, calendar.tenant_id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # Return paths
  defp return_path("show_tenant", tenant_id) do
    ~p"/tenants/#{tenant_id}"
  end

  defp return_path("show_calendar", calendar_id) do
    calendar = SD.Calendars.get_calendar(calendar_id)

    ~p"/tenants/#{calendar.tenant_id}/calendars/#{calendar_id}"
  end
end
