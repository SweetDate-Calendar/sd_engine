defmodule SDWeb.TenantLive.Form do
  use SDWeb, :live_view

  alias SD.Tenants
  alias SD.Tenants.Tenant

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage tenant records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="tenant-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Tenant</.button>
          <.button navigate={return_path(@return_to, @tenant)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    tenant = Tenants.get_tenant(id)

    socket
    |> assign(:page_title, "Edit Tenant")
    |> assign(:tenant, tenant)
    |> assign(:form, to_form(Tenants.change_tenant(tenant)))
  end

  defp apply_action(socket, :new, _params) do
    tenant = %Tenant{}

    socket
    |> assign(:page_title, "New Tenant")
    |> assign(:tenant, tenant)
    |> assign(:form, to_form(Tenants.change_tenant(tenant)))
  end

  @impl true
  def handle_event("validate", %{"tenant" => tenant_params}, socket) do
    changeset = Tenants.change_tenant(socket.assigns.tenant, tenant_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"tenant" => tenant_params}, socket) do
    save_tenant(socket, socket.assigns.live_action, tenant_params)
  end

  defp save_tenant(socket, :edit, tenant_params) do
    case Tenants.update_tenant(socket.assigns.tenant, tenant_params) do
      {:ok, tenant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tenant updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, tenant))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_tenant(socket, :new, tenant_params) do
    case Tenants.create_tenant(tenant_params) do
      {:ok, tenant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tenant created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, tenant))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _tenant), do: ~p"/tenants"
  defp return_path("show", tenant), do: ~p"/tenants/#{tenant}"
end
