defmodule SD.CredentialsFixtures do
  @doc """
  Generate a unique credential app_id.
  """
  def unique_credential_app_id do
    "app_" <> Integer.to_string(System.unique_integer([:positive]))
  end

  @doc """
  Create and return a valid `%Credential{}`.

  You can override any field via `attrs`, for example:
      credential_fixture(%{app_id: "app_demo"})
      credential_fixture(%{status: :disabled})
      credential_fixture(%{public_key: Base.url_encode64(pub, padding: false)})
  """
  def credential_fixture(attrs \\ %{}) do
    {pub_b64, _priv} = ensure_pubkey(attrs)

    defaults = %{
      app_id: unique_credential_app_id(),
      public_key: pub_b64,
      alg: :ed25519,
      status: :active,
      # set timestamps to something sensible for tests; override as needed
      expires_at: nil,
      last_used_at: nil
    }

    {:ok, credential} =
      attrs
      # attrs take precedence
      |> Map.merge(defaults, fn _k, v1, _v2 -> v1 end)
      |> SD.Account.create_credential()

    credential
  end

  @doc """
  Same as `credential_fixture/1`, but also returns the **private key** so you
  can sign requests in end-to-end tests.

      {credential, priv_key} = credential_with_priv_fixture()
  """
  def credential_with_priv_fixture(attrs \\ %{}) do
    {pub_b64, priv} = ensure_pubkey(attrs)

    cred =
      attrs
      |> Map.put_new(:public_key, pub_b64)
      |> credential_fixture()

    {cred, priv}
  end

  ## Internal helpers

  # If attrs already includes a base64/base64url public_key, use it.
  # Otherwise generate a fresh Ed25519 keypair and return {pub_b64url, priv_bin}.
  defp ensure_pubkey(%{public_key: pk}) when is_binary(pk) do
    {pk, nil}
  end

  defp ensure_pubkey(_attrs) do
    {pub, priv} = :crypto.generate_key(:eddsa, :ed25519)
    # base64url, no padding
    pub_b64 = Base.url_encode64(pub, padding: false)
    {pub_b64, priv}
  end
end
