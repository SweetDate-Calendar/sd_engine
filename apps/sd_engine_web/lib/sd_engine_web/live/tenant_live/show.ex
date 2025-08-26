defmodule SDWeb.TenantLive.Show do
  use SDWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Tenant ID: {@tenant.id}
        <:actions>
          <.button navigate={~p"/"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            id={"edit-tenant-#{@tenant.id}"}
            navigate={~p"/tenants/#{@tenant}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit tenant
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@tenant.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    tenant =
      SD.Tenants.get_tenant(id)

    {:ok,
     socket
     |> assign(:page_title, "Show Tenant")
     |> assign(:tenant, tenant)}
  end
end
