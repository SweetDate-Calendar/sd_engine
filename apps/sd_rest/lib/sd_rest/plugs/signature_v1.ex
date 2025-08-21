defmodule SDRest.Plugs.SignatureV1 do
  @behaviour Plug
  import Plug.Conn

  # seconds
  @default_skew 300

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts), do: verify_request(conn, opts)

  defp verify_request(conn, opts) do
    resolver = Keyword.get(opts, :resolver)
    skew = Keyword.get(opts, :skew, @default_skew)

    with {:ok, app_id} <- get_header(conn, "sd-app-id"),
         {:ok, ts_str} <- get_header(conn, "sd-timestamp"),
         {:ok, ts} <- parse_int(ts_str),
         :ok <- check_skew(ts, skew),
         {:ok, sig_b64} <- get_header(conn, "sd-signature"),
         {:ok, sig} <- urlsafe_decode(sig_b64),
         {:ok, pubkey} <- resolve_pubkey(resolver, app_id),
         message <- canonical(conn, ts),
         true <- verify_ed25519(message, sig, pubkey) do
      conn
      |> assign(:sd_app_id, app_id)
      |> assign(:sd_auth_v1, true)
    else
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, ~s({"error":"unauthorized"}))
        |> halt()
    end
  end

  # -- helpers --

  defp get_header(conn, name) do
    case get_req_header(conn, name) do
      [v | _] ->
        v = String.trim(v)
        if v == "", do: :error, else: {:ok, v}

      _ ->
        :error
    end
  end

  defp parse_int(str) do
    case Integer.parse(str) do
      {i, ""} -> {:ok, i}
      _ -> :error
    end
  end

  defp check_skew(ts, skew) when is_integer(ts) and is_integer(skew) do
    now = System.os_time(:second)
    if abs(now - ts) <= skew, do: :ok, else: :error
  end

  # v1-min canonical: no body hash; trailing "-" placeholder
  defp canonical(conn, ts) do
    method = String.upcase(conn.method || "")

    path_q =
      case conn.query_string do
        nil -> conn.request_path
        "" -> conn.request_path
        qs -> conn.request_path <> "?" <> qs
      end

    Enum.join(["v1", method, path_q, Integer.to_string(ts), "-"], "\n")
  end

  # resolver: (app_id :: binary -> {:ok, pubkey32} | :error)
  defp resolve_pubkey(resolver, app_id) when is_function(resolver, 1), do: resolver.(app_id)
  defp resolve_pubkey(_, _), do: :error

  defp verify_ed25519(message, signature, pubkey32)
       when is_binary(message) and is_binary(signature) and is_binary(pubkey32) and
              byte_size(pubkey32) == 32 do
    :crypto.verify(:eddsa, :none, message, signature, [pubkey32, :ed25519])
  end

  defp verify_ed25519(_, _, _), do: false

  defp urlsafe_decode(b64url) when is_binary(b64url) do
    case Base.url_decode64(b64url, padding: false) do
      {:ok, bin} -> {:ok, bin}
      :error -> :error
    end
  end
end
