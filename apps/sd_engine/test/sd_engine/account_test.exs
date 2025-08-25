defmodule SD.AccountTest do
  use SD.DataCase, async: true

  alias SD.Account
  alias SD.Account.Credential

  import SD.CredentialsFixtures

  @invalid_attrs %{
    status: nil,
    public_key: nil,
    app_id: nil,
    alg: nil,
    expires_at: nil,
    last_used_at: nil
  }

  describe "credentials" do
    test "list_credentials/0 returns all credentials" do
      credential = credential_fixture()
      assert Account.list_credentials() == [credential]
    end

    test "get_credential!/1 returns the credential with given id" do
      credential = credential_fixture()
      assert Account.get_credential!(credential.id) == credential
    end

    test "get_active_credential_by_app_id/1 returns the credential when app_id exists and is active" do
      cred = credential_fixture(%{app_id: "app_123", status: :active})

      result = Account.get_active_credential_by_app_id("app_123")
      assert %Credential{} = result
      assert result.id == cred.id
    end

    test "get_active_credential_by_app_id/1 returns nil when the app_id does not exist" do
      assert Account.get_active_credential_by_app_id("missing") == nil
    end

    test "get_active_credential_by_app_id/1 returns nil when the credential is not active" do
      _cred = credential_fixture(%{app_id: "app_disabled", status: :disabled})
      assert Account.get_active_credential_by_app_id("app_disabled") == nil
    end

    test "create_credential/1 with valid data creates a credential" do
      # generate a real Ed25519 keypair and encode pubkey base64url (no padding)
      {pub, _priv} = :crypto.generate_key(:eddsa, :ed25519)
      pub_b64 = Base.url_encode64(pub, padding: false)

      valid_attrs = %{
        status: :active,
        public_key: pub_b64,
        app_id: "some_app_id",
        alg: :ed25519,
        expires_at: ~U[2025-08-18 09:20:00.000000Z],
        last_used_at: ~U[2025-08-18 09:20:00.000000Z]
      }

      assert {:ok, %Credential{} = credential} = Account.create_credential(valid_attrs)
      assert credential.status == :active
      assert credential.public_key == pub_b64
      assert credential.app_id == "some_app_id"
      assert credential.alg == :ed25519
      assert credential.expires_at == ~U[2025-08-18 09:20:00.000000Z]
      assert credential.last_used_at == ~U[2025-08-18 09:20:00.000000Z]
    end

    test "create_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_credential(@invalid_attrs)
    end

    test "update_credential/2 with valid data updates the credential" do
      credential = credential_fixture()

      # new valid pubkey for update
      {pub2, _priv2} = :crypto.generate_key(:eddsa, :ed25519)
      pub2_b64 = Base.url_encode64(pub2, padding: false)

      update_attrs = %{
        # keep valid enum
        status: :active,
        # valid new key
        public_key: pub2_b64,
        app_id: "some_updated_app_id",
        # enum value, not string
        alg: :ed25519,
        expires_at: ~U[2025-08-19 09:20:00.000000Z],
        last_used_at: ~U[2025-08-19 09:20:00.000000Z]
      }

      assert {:ok, %Credential{} = credential} =
               Account.update_credential(credential, update_attrs)

      assert credential.status == :active
      assert credential.public_key == pub2_b64
      assert credential.app_id == "some_updated_app_id"
      assert credential.alg == :ed25519
      assert credential.expires_at == ~U[2025-08-19 09:20:00.000000Z]
      assert credential.last_used_at == ~U[2025-08-19 09:20:00.000000Z]
    end

    test "update_credential/2 with invalid data returns error changeset and leaves record unchanged" do
      credential = credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_credential(credential, @invalid_attrs)
      assert credential == Account.get_credential!(credential.id)
    end

    test "delete_credential/1 deletes the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{}} = Account.delete_credential(credential)
      assert_raise Ecto.NoResultsError, fn -> Account.get_credential!(credential.id) end
    end

    test "change_credential/1 returns a credential changeset" do
      credential = credential_fixture()
      assert %Ecto.Changeset{} = Account.change_credential(credential)
    end
  end
end
