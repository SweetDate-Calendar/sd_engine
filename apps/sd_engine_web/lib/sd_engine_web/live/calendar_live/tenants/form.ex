defmodule SDWeb.Tenants.CalendarLive.Form do
  alias SD.Tenants
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

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Calendar</.button>
          <.button navigate={return_path(@return_to, @tenant_id, @calendar)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"tenant_id" => tenant_id, "return_to" => return_to} = params, _session, socket) do
    {:ok,
     socket
     |> assign(return_to_id: return_to)
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:tenant_id, tenant_id)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show_calendar"), do: "show_calendar"
  defp return_to(_), do: "show_tenant"

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
    calendar = %Calendar{}

    socket
    |> assign(:page_title, "New Calendar")
    |> assign(:calendar, calendar)
    |> assign(:form, to_form(Calendars.change_calendar(calendar, %{tenant_id: tenant_id})))
  end

  defp save_calendar(socket, :new, calendar_params) do
    case Tenants.add_calendar(socket.assigns.tenant_id, calendar_params) do
      # New shape
      {:ok, %SD.Calendars.Calendar{} = calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.return_to, socket.assigns.tenant_id, calendar)
         )}

      # Legacy shape (accept during transition)
      {:ok, %{calendar: %SD.Calendars.Calendar{} = calendar}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.return_to, socket.assigns.tenant_id, calendar)
         )}

      {:error, _failed_op, %Ecto.Changeset{} = changeset, _changes_so_far} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_calendar(socket, :edit, calendar_params) do
    tenant_id = socket.assigns.tenant_id

    case Calendars.update_calendar(socket.assigns.calendar, calendar_params) do
      {:ok, calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, tenant_id, calendar))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
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

  defp return_path("show_tenant", tenant_id, _), do: ~p"/tenants/#{tenant_id}"

  defp return_path("show_calendar", tenant_id, calendar),
    do: ~p"/tenants/#{tenant_id}/calendars/#{calendar}"
end
