defmodule SDTCP.Handlers.Tenants do
  def dispatch("LIST", _json) do
    %{status: "ok", tenants: SD.Tenants.list_tenants()}
  end

  def dispatch("CREATE", json) do
    case Jason.decode(json) do
      {:ok, attrs} ->
        case SD.Accounts.create_tenant(attrs) do
          {:ok, tenant} -> %{status: "ok", tenant: tenant}
          {:error, cs} -> %{status: "error", errors: cs.errors}
        end

      _ ->
        %{status: "error", message: "invalid json"}
    end
  end

  def dispatch("GET", json) do
    case Jason.decode(json) do
      {:ok, %{"id" => id}} ->
        case SD.Tenants.get_tenant(id) do
          %SD.Tenants.Tenant{} = tenant ->
            %{status: "ok", tenant: %{"id" => tenant.id, "name" => tenant.name}}

          nil ->
            %{status: "error", message: "not found"}
        end

      _ ->
        %{status: "error", message: "invalid json"}
    end
  end

  def dispatch("UPDATE", json) do
    with {:ok, %{"id" => id} = attrs} <- Jason.decode(json),
         cal <- SD.Tenants.get_tenant(id),
         {:ok, updated} <- SD.Tenants.update_tenant(cal, attrs) do
      %{status: "ok", tenant: updated}
    else
      {:error, changeset} -> %{status: "error", errors: changeset.errors}
      _ -> %{status: "error", message: "invalid input or not found"}
    end
  end

  def dispatch("DELETE", json) do
    with {:ok, %{"id" => id}} <- Jason.decode(json),
         cal <- SD.Tenants.get_tenant(id),
         {:ok, _} <- SD.Tenants.delete_tenant(cal) do
      %{status: "ok"}
    else
      _ -> %{status: "error", message: "not found or failed to delete"}
    end
  end
end
