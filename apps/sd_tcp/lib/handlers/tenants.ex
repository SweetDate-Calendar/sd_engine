defmodule SDTCP.Handlers.Tenants do
  import SDTCP.Handlers.Helpers, only: [format_errors: 1]

  def dispatch("LIST", payload) do
    tenants =
      case payload["sweet_date_account_id"] do
        nil -> []
        account_id -> SD.Tenants.list_tenants(account_id)
      end

    %{status: "ok", tenants: tenants}
  end

  def dispatch("CREATE", %{"sweet_date_api_key_id" => account_id, "name" => name}) do
    case SD.Accounts.create_tenant(%{account_id: account_id, name: name}) do
      {:ok, %SD.Tenants.Tenant{} = tenant} ->
        Phoenix.PubSub.broadcast(
          SD.PubSub,
          "account:#{account_id}",
          {:tenant_created, %{tenant: tenant}}
        )

        %{status: "ok", tenant: tenant}

      {:error, ch} ->
        %{status: "error", message: format_errors(ch.errors)}
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
      Phoenix.PubSub.broadcast(
        SD.PubSub,
        "account:#{tenant.account_id}",
        {:tenant_updated, %{tenant: tenant}}
      )

      %{status: "ok", tenant: tenant}
    else
      _ -> %{status: "error", message: "not found or failed to update"}
    end
  end

  def dispatch("DELETE", %{"id" => id}) when is_binary(id) do
    with %SD.Tenants.Tenant{} = tenant <- SD.Tenants.get_tenant(id),
         {:ok, tenant} <- SD.Tenants.delete_tenant(tenant) do
      Phoenix.PubSub.broadcast(
        SD.PubSub,
        "account:#{tenant.account_id}",
        {:tenant_deleted, %{tenant: tenant}}
      )

      %{status: "ok", tenant: tenant}
    else
      _ -> %{status: "error", message: "not found or failed to delete"}
    end
  end

  def dispatch(_, _) do
    %{status: "error", message: "Invalid payload"}
  end
end
