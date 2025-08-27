# test/support/signed_request_helpers.ex
defmodule SDRest.SignedRequestHelpers do
  @moduledoc false

  import Phoenix.ConnTest

  @app_id "app_test_fixed"
  @public_key "Clq6ZOkhPxrTZeDkfhayAQbUS9dHU65JGw1f0UlaOuA"
  @private_key "hYdg0McePak4jrRyyWFtj0pLlprc4WwDhWhGLxcrqak"

  defmacro __using__(_) do
    quote do
      @app_id unquote(@app_id)
      @private_key unquote(@private_key)

      setup :insert_test_credentials

      defp insert_test_credentials(_) do
        SD.CredentialsFixtures.credential_fixture(%{
          app_id: @app_id,
          public_key: unquote(@public_key),
          alg: :ed25519,
          status: :active
        })

        :ok
      end

      defp decode_private_key!(b64url) do
        case Base.url_decode64(b64url, padding: false) do
          {:ok, bin} -> bin
          :error -> raise "invalid base64url private key"
        end
      end

      defp sign_headers(method, full_path, ts \\ System.os_time(:second)) do
        method_up = method |> to_string() |> String.upcase()

        {path, qs} =
          case String.split(full_path, "?", parts: 2) do
            [p] -> {p, ""}
            [p, q] -> {p, q}
          end

        path_q = if qs == "", do: path, else: path <> "?" <> qs
        msg = Enum.join(["v1", method_up, path_q, Integer.to_string(ts), "-"], "\n")

        sig =
          :crypto.sign(:eddsa, :none, msg, [decode_private_key!(@private_key), :ed25519])
          |> Base.url_encode64(padding: false)

        [
          {"sd-app-id", @app_id},
          {"sd-timestamp", Integer.to_string(ts)},
          {"sd-signature", sig}
        ]
      end

      defp put_headers(conn, headers),
        do: Enum.reduce(headers, conn, fn {k, v}, acc -> put_req_header(acc, k, v) end)

      defp signed_get(conn, path),
        do: put_headers(conn, sign_headers(:get, path)) |> get(path)

      defp signed_post(conn, path, params),
        do:
          put_headers(conn, [{"content-type", "application/json"} | sign_headers(:post, path)])
          |> post(path, Jason.encode!(params))

      defp signed_put(conn, path, params),
        do:
          put_headers(conn, [{"content-type", "application/json"} | sign_headers(:put, path)])
          |> put(path, Jason.encode!(params))

      defp signed_delete(conn, path),
        do: put_headers(conn, sign_headers(:delete, path)) |> delete(path)
    end
  end
end
