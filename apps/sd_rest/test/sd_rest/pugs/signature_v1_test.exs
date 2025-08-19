defmodule SD_REST.Plugs.SignatureV1Test do
  use ExUnit.Case, async: true
  # Use your engine’s sandbox so DB inserts are isolated
  use SD.DataCase

  import Plug.Test
  import Plug.Conn
  import SD.AccountFixtures

  @opts SD_REST.Router.init([])

  defp base64url(bin), do: Base.url_encode64(bin, padding: false)

  defp canonical(method, path, query, ts) do
    path_q = if query in [nil, ""], do: path, else: path <> "?" <> query
    Enum.join(["v1", String.upcase(method), path_q, Integer.to_string(ts), "-"], "\n")
  end

  defp sign(msg, priv32), do: :crypto.sign(:eddsa, :none, msg, [priv32, :ed25519])

  test "authorized request passes and returns app_id" do
    {cred, priv} = credential_with_priv_fixture(%{app_id: "app_abc123", status: :active})

    ts  = System.os_time(:second)
    msg = canonical("GET", "/whoami", "", ts)
    sig = sign(msg, priv) |> base64url()

    conn =
      conn(:get, "/whoami")
      |> put_req_header("sd-app-id", cred.app_id)
      |> put_req_header("sd-timestamp", Integer.to_string(ts))
      |> put_req_header("sd-signature", sig)
      |> SD_REST.Router.call(@opts)

    assert conn.status == 200
    %{"status" => "ok", "app_id" => app_id} = Jason.decode!(conn.resp_body)
    assert app_id == cred.app_id
  end

  test "bad signature -> 401" do
    {cred, _priv} = credential_with_priv_fixture(%{app_id: "app_bad", status: :active})

    ts = System.os_time(:second)
    bad_sig = :crypto.strong_rand_bytes(64) |> base64url()

    conn =
      conn(:get, "/whoami")
      |> put_req_header("sd-app-id", cred.app_id)
      |> put_req_header("sd-timestamp", Integer.to_string(ts))
      |> put_req_header("sd-signature", bad_sig)
      |> SD_REST.Router.call(@opts)

    assert conn.status == 401
  end

  test "old timestamp -> 401" do
    {cred, priv} = credential_with_priv_fixture(%{app_id: "app_time", status: :active})

    ts  = System.os_time(:second) - 3600
    msg = canonical("GET", "/whoami", "", ts)
    sig = sign(msg, priv) |> base64url()

    conn =
      conn(:get, "/whoami")
      |> put_req_header("sd-app-id", cred.app_id)
      |> put_req_header("sd-timestamp", Integer.to_string(ts))
      |> put_req_header("sd-signature", sig)
      |> SD_REST.Router.call(@opts)

    assert conn.status == 401
  end

  test "health is public (no headers)" do
    conn = conn(:get, "/health") |> SD_REST.Router.call(@opts)
    assert conn.status == 200
    assert %{"status" => "ok"} = Jason.decode!(conn.resp_body)
  end
end
