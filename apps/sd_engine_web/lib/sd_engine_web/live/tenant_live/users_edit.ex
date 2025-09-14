defmodule SDWeb.TenantUsersEditLive.Form do
  use SDWeb, :live_view
  alias SD.Tenants
  alias SD.Tenants.TenantUser

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Edit User Role
        <:subtitle>User: {@user.name} (#{@user.email})</:subtitle>
        <:actions>
          <.button navigate={~p"/tenants/#{@tenant.id}/users"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.form for={@form} id="tenant-user-edit-form" phx-submit="save">
        <.input
          field={@form[:role]}
          type="select"
          label="Role"
          options={[
            {"Owner", :owner},
            {"Admin", :admin},
            {"Guest", :guest}
            ]}
        />

        <footer>
          <.button phx-disable-with="Updating..." variant="primary">
            Update Role
          </.button>
          <.button navigate={~p"/tenants/#{@tenant.id}/users"}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"tenant_id" => tenant_id, "id" => user_id}, _session, socket) do
    tenant = Tenants.get_tenant(tenant_id)
    {:ok, tenant_user} = Tenants.get_tenant_user(tenant_id, user_id)
    user = SD.Repo.preload(tenant_user, :user).user

    changeset = TenantUser.changeset(tenant_user, %{})

    {:ok,
     socket
     |> assign(:tenant, tenant)
     |> assign(:tenant_user, tenant_user)
     |> assign(:user, user)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"tenant_user" => params}, socket) do
    case Tenants.update_tenant_user(socket.assigns.tenant_user, params) do
      {:ok, _tenant_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Role updated successfully")
         |> push_navigate(to: ~p"/tenants/#{socket.assigns.tenant.id}/users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
