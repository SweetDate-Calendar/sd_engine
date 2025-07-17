defmodule SDTCP.Handlers.Tiers do
  def dispatch("LIST", payload) do
    tiers =
      case payload["sweet_date_account_id"] do
        nil -> []
        account_id -> SD.Tiers.list_tiers(account_id)
      end

    %{status: "ok", tiers: tiers}
  end

  def dispatch("CREATE", %{"sweet_date_account_id" => account_id, "name" => name}) do
    case SD.Accounts.create_tier(%{account_id: account_id, name: name}) do
      {:ok, %SD.Tiers.Tier{} = tier} ->
        Phoenix.PubSub.broadcast(
          SD.PubSub,
          "account:#{account_id}",
          {:tier_created, %{tier: tier}}
        )

        %{status: "ok", message: tier.id}

      {:error, ch} ->
        %{status: "error", message: format_errors(ch.errors)}
    end
  end

  def dispatch("GET", %{"id" => id}) when is_binary(id) do
    case SD.Tiers.get_tier(id) do
      %SD.Tiers.Tier{} = tier ->
        %{status: "ok", message: %{"name" => tier.name}}

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch("UPDATE", %{"id" => id, "name" => name}) do
    with %SD.Tiers.Tier{} = tier <- SD.Tiers.get_tier(id),
         {:ok, tier} <- SD.Tiers.update_tier(tier, %{name: name}) do
      Phoenix.PubSub.broadcast(
        SD.PubSub,
        "account:#{tier.account_id}",
        {:tier_updated, %{tier: tier}}
      )

      %{status: "ok", message: "tier updated"}
    else
      _ -> %{status: "error", message: "not found or failed to update"}
    end
  end

  def dispatch("DELETE", %{"id" => id}) when is_binary(id) do
    with %SD.Tiers.Tier{} = tier <- SD.Tiers.get_tier(id),
         {:ok, tier} <- SD.Tiers.delete_tier(tier) do
      Phoenix.PubSub.broadcast(
        SD.PubSub,
        "account:#{tier.account_id}",
        {:tier_deleted, %{tier: tier}}
      )

      %{status: "ok", message: "tier deleted"}
    else
      _ -> %{status: "error", message: "not found or failed to delete"}
    end
  end

  def dispatch(_, _) do
    %{status: "error", message: "Invalid payload"}
  end

  defp format_errors(errors) do
    for {field, {msg, _meta}} <- errors do
      "#{field} #{msg}"
    end
  end
end
