defmodule SDTCP.Handlers.Tiers do
  def dispatch("LIST", _json) do
    %{status: "ok", tiers: SD.Tiers.list_tiers()}
  end

  def dispatch("CREATE", json) do
    case Jason.decode(json) do
      {:ok, attrs} ->
        case SD.Accounts.create_tier(attrs) do
          {:ok, cal} -> %{status: "ok", id: cal.id}
          {:error, cs} -> %{status: "error", errors: cs.errors}
        end

      _ ->
        %{status: "error", message: "invalid json"}
    end
  end

  def dispatch("GET", json) do
    case Jason.decode(json) do
      {:ok, %{"id" => id}} ->
        case SD.Tiers.get_tier(id) do
          %SD.Tiers.Tier{} = tier ->
            %{status: "ok", tier: %{"id" => tier.id, "name" => tier.name}}

          nil ->
            %{status: "error", message: "not found"}
        end

      _ ->
        %{status: "error", message: "invalid json"}
    end
  end

  def dispatch("UPDATE", json) do
    with {:ok, %{"id" => id} = attrs} <- Jason.decode(json),
         cal <- SD.Tiers.get_tier(id),
         {:ok, updated} <- SD.Tiers.update_tier(cal, attrs) do
      %{status: "ok", tier: updated}
    else
      {:error, changeset} -> %{status: "error", errors: changeset.errors}
      _ -> %{status: "error", message: "invalid input or not found"}
    end
  end

  def dispatch("DELETE", json) do
    with {:ok, %{"id" => id}} <- Jason.decode(json),
         cal <- SD.Tiers.get_tier(id),
         {:ok, _} <- SD.Tiers.delete_tier(cal) do
      %{status: "ok"}
    else
      _ -> %{status: "error", message: "not found or failed to delete"}
    end
  end
end
