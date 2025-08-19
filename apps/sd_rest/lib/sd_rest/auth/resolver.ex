defmodule SD_REST.Auth.Resolver do
  @moduledoc false

  def pubkey(app_id) when is_binary(app_id) do
    case SD.Account.get_active_credential_by_app_id(app_id) do
      nil ->
        :error

      cred ->
        with pk_b64 when is_binary(pk_b64) <- Map.get(cred, :public_key),
             alg <- Map.get(cred, :alg),
             true <- alg in [:ed25519, "ed25519"],
             {:ok, bin} <- decode_pubkey(pk_b64),
             true <- byte_size(bin) == 32 do
          {:ok, bin}
        else
          _ -> :error
        end
    end
  end

  defp decode_pubkey(s) when is_binary(s) do
    case Base.url_decode64(s, padding: false) do
      {:ok, bin} when byte_size(bin) == 32 -> {:ok, bin}
      _ -> :error
    end
  end
end
