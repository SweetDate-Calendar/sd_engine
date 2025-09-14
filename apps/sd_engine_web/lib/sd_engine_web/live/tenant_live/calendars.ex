defmodule SDWeb.TenantCalendarsLive.Form do
  use SDWeb, :live_view

  alias SD.Tenants
  alias SD.Tenants.TenantCalendar

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Calendars
        <:subtitle>Tenant: {@tenant.name} - ID: {@tenant.id}</:subtitle>
        <:actions>
          <.button navigate={~p"/tenants/#{@tenant}"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.form for={@form} id="tenant-calendar-form" phx-submit="save">
        <.input
          field={@form[:calendar_id]}
          type="select"
          label="Select"
          options={@calendar_options}
        />

        <footer>
          <.button phx-disable-with="Assigning..." variant="primary">
            Assign Calendar
          </.button>
          <.button navigate={~p"/tenants/#{@tenant.id}"}>Cancel</.button>
        </footer>
      </.form>

      <.header class="mt-14">
        <:subtitle>Calendars assigned to this tenant.</:subtitle>
      </.header>
      <.table
        id="calendars"
        rows={@streams.calendars}
        row_click={fn {_id, calendar} -> JS.navigate(~p"/calendars/#{calendar}") end}
        >
        <:col :let={{_id, calendar}} label="Name">
          <span id={"calendar-name-#{calendar.id}"}><%= calendar.name %></span>
        </:col>
        <:col :let={{_id, calendar}} label="Color theme">{calendar.color_theme}</:col>
        <:col :let={{_id, calendar}} label="Visibility">{calendar.visibility}</:col>

        <:action :let={{id, calendar}}>
          <.link
            phx-click={JS.push("delete", value: %{id: calendar.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Remove
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => tenant_id}, _session, socket) do
    tenant =
      Tenants.get_tenant(tenant_id)
      |> SD.Repo.preload(:calendars)

    calendars = SD.SweetDate.list_calendars()
    calendar_options = Enum.map(calendars, fn c -> {c.name, c.id} end)

    changeset =
      TenantCalendar.changeset(%TenantCalendar{}, %{
        tenant_id: tenant.id,
        calendar_id: nil
      })

    {:ok,
     socket
     |> assign(:tenant, tenant)
     |> assign(:calendar_options, calendar_options)
     |> stream(:calendars, tenant.calendars)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"tenant_calendar" => params}, socket) do
    params = Map.put(params, "tenant_id", socket.assigns.tenant.id)

    case Tenants.create_tenant_calendar(params) do
      {:ok, tenant_calendar} ->
        tenant_calendar = SD.Repo.preload(tenant_calendar, :calendar)

        {:noreply,
         socket
         |> put_flash(:info, "Calendar assigned successfully")
         |> stream_insert(:calendars, tenant_calendar.calendar)}

      {:error, %Ecto.Changeset{} = changeset} ->
        # Look for unique constraint violation on tenant_id+calendar_id
        case changeset.errors do
          [tenant_id: {"has already been taken", [constraint: :unique, constraint_name: _]}] ->
            {:noreply,
             socket
             |> put_flash(:error, "This calendar is already assigned to the tenant")
             |> assign(:form, to_form(changeset))}

          _ ->
            {:noreply, assign(socket, :form, to_form(changeset))}
        end
    end
  end

  # @impl true
  def handle_event("delete", %{"id" => calendar_id}, socket) do
    tenant_id = socket.assigns.tenant.id

    case Tenants.get_tenant_calendar(tenant_id, calendar_id) do
      {:ok, tenant_calendar} ->
        {:ok, _} = Tenants.delete_tenant_calendar(tenant_calendar)

        {:noreply,
         socket
         |> put_flash(:info, "Calendar removed successfully")
         |> stream_delete(:calendars, tenant_calendar.calendar)}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Calendar not found")}
    end
  end
end
