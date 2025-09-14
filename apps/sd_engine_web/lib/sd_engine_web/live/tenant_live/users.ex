defmodule SDWeb.TenantUsersLive.Form do
  use SDWeb, :live_view

  alias SD.Tenants
  alias SD.Tenants.TenantUser
  alias SD.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Users
        <:subtitle>Tenant: {@tenant.name} - ID: {@tenant.id}</:subtitle>
        <:actions>
          <.button navigate={~p"/tenants/#{@tenant}"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.form for={@form} id="tenant-user-form" phx-submit="save">
        <.input
          field={@form[:user_id]}
          type="select"
          label="Select User"
          options={@user_options}
        />

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
          <.button phx-disable-with="Assigning..." variant="primary">
            Assign User
          </.button>
          <.button navigate={~p"/tenants/#{@tenant.id}"}>Cancel</.button>
        </footer>
      </.form>

      <.header class="mt-14">
        <:subtitle>Users assigned to this tenant.</:subtitle>
      </.header>

      <.table
        id="users"
        rows={@streams.users}
        row_click={fn {_id, user} -> JS.navigate(~p"/users/#{user}") end}
      >
        <:col :let={{_id, user}} label="Name">
          <span id={"user-name-#{user.id}"}><%= user.name %></span>
        </:col>
        <:col :let={{_id, user}} label="Email">{user.email}</:col>
        <:col :let={{_id, user}} label="Role">{user.tenant_users |> hd() |> Map.get(:role)}</:col>

        <:action :let={{id, user}}>
          <.link navigate={~p"/tenants/#{@tenant.id}/users/#{user.id}/edit"}>Edit</.link>
          <.link
            phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")}
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
      |> SD.Repo.preload(users: [:tenant_users])

    users = Accounts.list_users()
    user_options = Enum.map(users, fn u -> {u.name, u.id} end)

    changeset =
      TenantUser.changeset(%TenantUser{}, %{
        tenant_id: tenant.id,
        user_id: nil,
        role: :guest
      })

    {:ok,
     socket
     |> assign(:tenant, tenant)
     |> assign(:user_options, user_options)
     |> stream(:users, tenant.users)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"tenant_user" => params}, socket) do
    params = Map.put(params, "tenant_id", socket.assigns.tenant.id)

    case Tenants.create_tenant_user(params) do
      {:ok, tenant_user} ->
        tenant_user =
          SD.Repo.preload(tenant_user, user: [:tenant_users])

        {:noreply,
         socket
         |> put_flash(:info, "User assigned successfully")
         |> stream_insert(:users, tenant_user.user)}

      {:error, %Ecto.Changeset{} = changeset} ->
        case changeset.errors do
          [tenant_id: {"has already been taken", [constraint: :unique, constraint_name: _]}] ->
            {:noreply,
             socket
             |> put_flash(:error, "This user is already assigned to the tenant")
             |> assign(:form, to_form(changeset))}

          _ ->
            {:noreply, assign(socket, :form, to_form(changeset))}
        end
    end
  end

  def handle_event("delete", %{"id" => user_id}, socket) do
    tenant_id = socket.assigns.tenant.id

    case Tenants.get_tenant_user(tenant_id, user_id) do
      {:ok, tenant_user} ->
        {:ok, _} = Tenants.delete_tenant_user(tenant_user)

        {:noreply,
         socket
         |> put_flash(:info, "User removed successfully")
         |> stream_delete(:users, tenant_user.user)}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "User not found")}
    end
  end
end
