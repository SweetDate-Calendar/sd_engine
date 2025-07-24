defmodule SDTCP.Handlers.Accounts do
  import SDTCP.Handlers.Helpers, only: [format_errors: 1]

  def dispatch("LIST", _json) do
    %{status: "ok", accounts: SD.Accounts.list_accounts()}
  end

  def dispatch("CREATE", %{"name" => name}) do
    case SD.Accounts.create_account(%{name: name}) do
      {:ok, %SD.Accounts.Account{} = account} ->
        %{status: "ok", account: account}

      {:error, changeset} ->
        %{status: "error", message: format_errors(changeset.errors)}
    end
  end

  def dispatch("GET", %{"id" => id}) do
    case SD.Accounts.get_account(id) do
      %SD.Accounts.Account{} = account ->
        %{status: "ok", account: account}

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch("UPDATE", %{"id" => id} = attrs) do
    case SD.Accounts.get_account(id) do
      %SD.Accounts.Account{} = account ->
        case SD.Accounts.update_account(account, attrs) do
          {:ok, updated} -> %{status: "ok", account: updated}
          {:error, changeset} -> %{status: "error", message: format_errors(changeset.errors)}
        end

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch("DELETE", %{"id" => id}) do
    case SD.Accounts.get_account(id) do
      %SD.Accounts.Account{} = account ->
        case SD.Accounts.delete_account(account) do
          {:ok, _} -> %{status: "ok"}
          {:error, _} -> %{status: "error", message: "failed to delete"}
        end

      nil ->
        %{status: "error", message: "not found"}
    end
  end
end
