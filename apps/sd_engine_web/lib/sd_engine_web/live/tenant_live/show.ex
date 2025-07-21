defmodule SDWeb.TenantLive.Show do
  use SDWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Tenant {@tenant.id}
        <:actions>
          <.button navigate={~p"/accounts/#{@tenant.account}"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            id={"edit-tenant-#{@tenant.id}"}
            navigate={~p"/accounts/#{@tenant.account}/tenants/#{@tenant}/edit?return_to=show_tenant"}
          >
            <.icon name="hero-pencil-square" /> Edit tenant
          </.button>

          <.button
            variant="primary"
            navigate={~p"/tenants/#{@tenant}/calendars/new?return_to=show_tenant"}
          >
            <.icon name="hero-plus" /> New Calendar
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@tenant.name}</:item>
      </.list>
      Calendars
      <.table
        id="calendars"
        rows={@streams.calendars}
        row_click={
          fn {_id, calendar} -> JS.navigate(~p"/tenants/#{@tenant.id}/calendars/#{calendar}") end
        }
      >
        <:col :let={{_id, calendar}} label="Name">{calendar.name}</:col>
        <:col :let={{_id, calendar}} label="Color theme">{calendar.color_theme}</:col>
        <:col :let={{_id, calendar}} label="Visibility">{calendar.visibility}</:col>
        <:action :let={{_id, calendar}}>
          <div class="sr-only">
            <.link navigate={~p"/tenants/#{calendar.tenant_id}/calendars/#{calendar}"}>Show</.link>
          </div>
          <.link
            id={"edit-calendar-#{calendar.id}"}
            navigate={
              ~p"/tenants/#{calendar.tenant_id}/calendars/#{calendar}/edit?return_to=show_tenant"
            }
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
    tenant = SD.Tenants.get_tenant(id) |> SD.Repo.preload([:calendars, :account])

    {:ok,
     socket
     |> assign(:page_title, "Show Tenant")
     |> stream(:calendars, tenant.calendars)
     |> assign(:tenant, tenant)}
  end

  @impl true
  def handle_event("delete_calendar", %{"calendar_id" => calendar_id}, socket) do
    calendar = SD.Calendars.get_calendar(calendar_id)
    {:ok, _} = SD.Calendars.delete_calendar(calendar)

    {:noreply, stream_delete(socket, :calendars, calendar)}
  end
end
