defmodule SDTCP.Handlers.Auth do
  require Logger

  # def dispatch("CREATE", json) do
  #   case Jason.decode(json) do
  #     {:ok, attrs} ->
  #       handle_create(attrs)

  #     {:error, error} ->
  #       Logger.error("JSON decode failed: #{inspect(error)} for input: #{inspect(json)}")
  #       %{status: "error", message: "invalid json"}
  #   end
  # end

  # def dispatch("GET", json) do
  #   case Jason.decode(json) do
  #     {:ok, %{"secret_key_id" => id, "secret_key" => key}} ->
  #       case SDTCP.Auth.get_by_key(id, key) do
  #         nil -> %{status: "error", message: "not found"}
  #         auth -> %{status: "ok", authorization_hold: serialize(auth)}
  #       end

  #     _ ->
  #       %{status: "error", message: "invalid json"}
  #   end
  # end

  # def dispatch("LIST", _json) do
  #   auths = SDTCP.Auth.list_authorization_holds()
  #   %{status: "ok", authorization_holds: Enum.map(auths, &serialize/1)}
  # end

  # def dispatch("UPDATE", json) do
  #   case Jason.decode(json) do
  #     {:ok, %{"secret_key_id" => id, "secret_key" => key} = attrs} ->
  #       with auth when not is_nil(auth) <- CP.Auth.get_by_key(id, key),
  #            {:ok, updated} <- SDTCP.Auth.update_authorization_hold(auth, attrs) do
  #         %{status: "ok", authorization_hold: serialize(updated)}
  #       else
  #         nil -> %{status: "error", message: "not found"}
  #         {:error, cs} -> %{status: "error", errors: cs.errors}
  #       end

  #     _ ->
  #       %{status: "error", message: "invalid json"}
  #   end
  # end

  # def dispatch("DELETE", json) do
  #   case Jason.decode(json) do
  #     {:ok, %{"secret_key_id" => id, "secret_key" => key}} ->
  #       with auth when not is_nil(auth) <- CP.Auth.get_by_key(id, key),
  #            {:ok, _} <- SDTCP.Auth.delete_authorization_hold(auth) do
  #         %{status: "ok"}
  #       else
  #         _ -> %{status: "error", message: "not found"}
  #       end

  #     _ ->
  #       %{status: "error", message: "invalid json"}
  #   end
  # end

  # def dispatch(_, _), do: %{status: "error", message: "unknown command"}

  # defp serialize(auth) do
  #   %{
  #     id: auth.id,
  #     secret_key_id: auth.secret_key_id,
  #     tenant: to_string(auth.tenant),
  #     active: auth.active,
  #     metadata: auth.metadata,
  #     account_id: auth.account_id
  #   }
  # end

  # defp handle_create(attrs) do
  #   if attrs["provisioning_key"] == Application.get_env(:cp_tcp, :provisioning_key) do
  #     case SDTCP.Auth.create_authorization_hold(attrs) do
  #       {:ok, _hold} ->
  #         %{status: "ok"}

  #       {:error, cs} ->
  #         Logger.error(cs)
  #         %{status: "error", errors: cs.errors}
  #     end
  #   else
  #     %{status: "error", message: "unauthorized"}
  #   end
  # end
end
