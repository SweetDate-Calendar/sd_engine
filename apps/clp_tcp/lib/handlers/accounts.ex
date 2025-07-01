defmodule ClpTcp.Handlers.Accounts do
  def dispatch("LIST", _json) do
    %{status: "ok", accounts: CLP.Accounts.list_accounts()}
  end

  def dispatch("CREATE", json) do
    case Jason.decode(json) do
      {:ok, attrs} ->
        case CLP.Accounts.create_account(attrs) do
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
        case CLP.Accounts.get_account(id) do
          %CLP.Accounts.Account{} = account ->
            %{status: "ok", account: %{"id" => account.id, "name" => account.name}}

          nil ->
            %{status: "error", message: "not found"}
        end

      _ ->
        %{status: "error", message: "invalid json"}
    end
  end

  def dispatch("UPDATE", json) do
    with {:ok, %{"id" => id} = attrs} <- Jason.decode(json),
         cal <- CLP.Accounts.get_account(id),
         {:ok, updated} <- CLP.Accounts.update_account(cal, attrs) do
      %{status: "ok", account: updated}
    else
      {:error, changeset} -> %{status: "error", errors: changeset.errors}
      _ -> %{status: "error", message: "invalid input or not found"}
    end
  end

  def dispatch("DELETE", json) do
    with {:ok, %{"id" => id}} <- Jason.decode(json),
         cal <- CLP.Accounts.get_account(id),
         {:ok, _} <- CLP.Accounts.delete_account(cal) do
      %{status: "ok"}
    else
      _ -> %{status: "error", message: "not found or failed to delete"}
    end
  end
end
