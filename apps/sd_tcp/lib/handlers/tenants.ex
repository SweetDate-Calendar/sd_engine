defmodule SDTCP.Handlers.Tenants do
  import SDTCP.Handlers.Helpers, only: [format_errors: 1]

  def dispatch("LIST", %{}) do
    tenants = SD.Tenants.list_tenants()

    %{status: "ok", tenants: tenants}
  end

  def dispatch("CREATE", attrs) do
    case SD.Tenants.create_tenant(attrs) do
      {:ok, %SD.Tenants.Tenant{} = tenant} ->
        %{status: "ok", tenant: tenant}

      {:error, tenant} ->
        %{status: "error", message: format_errors(tenant.errors)}
    end
  end

  def dispatch("GET", %{"id" => id}) when is_binary(id) do
    case SD.Tenants.get_tenant(id) do
      %SD.Tenants.Tenant{} = tenant ->
        %{status: "ok", tenant: tenant}

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch("UPDATE", %{"id" => id, "name" => name}) do
    with %SD.Tenants.Tenant{} = tenant <- SD.Tenants.get_tenant(id),
         {:ok, tenant} <- SD.Tenants.update_tenant(tenant, %{name: name}) do
      %{status: "ok", tenant: tenant}
    else
      _ -> %{status: "error", message: "not found or failed to update"}
    end
  end

  def dispatch("DELETE", %{"id" => id}) when is_binary(id) do
    with %SD.Tenants.Tenant{} = tenant <- SD.Tenants.get_tenant(id),
         {:ok, tenant} <- SD.Tenants.delete_tenant(tenant) do
      %{status: "ok", tenant: tenant}
    else
      _ -> %{status: "error", message: "not found or failed to delete"}
    end
  end

  def dispatch(_, _) do
    %{status: "error", message: "Invalid payload"}
  end
end
