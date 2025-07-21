defmodule SDWeb.AccountLive.Show do
  use SDWeb, :live_view

  alias SD.Accounts
  alias SD.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Account {@account.id}
        <:actions>
          <.button navigate={~p"/accounts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            id="edit-account-btn"
            navigate={~p"/accounts/#{@account}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit account
          </.button>

          <.button
            variant="primary"
            navigate={~p"/accounts/#{@account}/tenants/new?return_to=show_account"}
          >
            <.icon name="hero-plus" /> New Tenant
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@account.name}</:item>
      </.list>
      Tenants
      <.table
        id="tenants"
        rows={@streams.tenants}
        row_click={fn {_id, tenant} -> JS.navigate(~p"/accounts/#{@account}/tenants/#{tenant}") end}
      >
        <:col :let={{_id, tenant}} label="Name">{tenant.name}</:col>
        <:action :let={{_id, tenant}}>
          <div class="sr-only">
            <.link navigate={~p"/accounts/#{tenant.account_id}/tenants/#{tenant}"}>Show</.link>
          </div>
          <.link
            id={"edit-tenant-#{tenant.id}"}
            navigate={
              ~p"/accounts/#{tenant.account_id}/tenants/#{tenant}/edit?return_to=show_account"
            }
          >
            Edit
          </.link>
        </:action>
        <:action :let={{id, tenant}}>
          <.link
            phx-click={JS.push("delete_tenant", value: %{tenant_id: tenant.id}) |> hide("##{id}")}
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
    account = Accounts.get_account(id) |> Repo.preload(:tenants)

    {:ok,
     socket
     |> assign(:page_title, "Show Account")
     |> stream(:tenants, account.tenants)
     |> assign(:account, account)}
  end

  @impl true
  def handle_event("delete_tenant", %{"tenant_id" => tenant_id}, socket) do
    tenant = SD.Tenants.get_tenant(tenant_id)
    {:ok, _} = SD.Tenants.delete_tenant(tenant)

    {:noreply, stream_delete(socket, :tenants, tenant)}
  end
end
