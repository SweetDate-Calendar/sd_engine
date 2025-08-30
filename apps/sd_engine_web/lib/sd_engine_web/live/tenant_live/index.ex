defmodule SDWeb.TenantLive.Index do
  use SDWeb, :live_view

  alias SD.Tenants

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Tenants
        <:actions>
          <.button variant="primary" navigate={~p"/tenants/new"}>
            <.icon name="hero-plus" /> New Tenant
          </.button>
        </:actions>
      </.header>

      <.table
        id="tenants"
        rows={@streams.tenants}
        row_click={fn {_id, tenant} -> JS.navigate(~p"/tenants/#{tenant}") end}
      >
        <:col :let={{_id, tenant}} label="Name">{tenant.name}</:col>
        <:action :let={{_id, tenant}}>
          <div class="sr-only">
            <.link navigate={~p"/tenants/#{tenant}"}>Show</.link>
          </div>
          <.link navigate={~p"/tenants/#{tenant}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, tenant}}>
          <.link
            phx-click={JS.push("delete", value: %{id: tenant.id}) |> hide("##{id}")}
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
    if connected?(socket), do: SDWeb.Endpoint.subscribe("tenants")

    {:ok,
     socket
     |> assign(:page_title, "Listing Tenants")
     |> stream(:tenants, Tenants.list_tenants())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = Tenants.get_tenant(id)
    {:ok, _} = Tenants.delete_tenant(tenant)

    {:noreply, stream_delete(socket, :tenants, tenant)}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "created", payload: tenant}, socket) do
    {:noreply, stream_insert(socket, :tenants, tenant, at: 0)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "tenants", event: "updated", payload: %{tenant: tenant}},
        socket
      ) do
    {:noreply, stream_insert(socket, :tenants, tenant)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: "tenants", event: "deleted", payload: %{tenant: tenant}},
        socket
      ) do
    {:noreply, stream_delete(socket, :tenants, tenant)}
  end
end
