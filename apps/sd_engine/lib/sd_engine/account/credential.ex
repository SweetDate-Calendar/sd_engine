defmodule SD.Account.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "credentials" do
    field :app_id, :string
    field :public_key, :string
    field :alg, Ecto.Enum, values: [:ed25519], default: :ed25519
    field :status, Ecto.Enum, values: [:active, :disabled], default: :active
    field :expires_at, :utc_datetime_usec
    field :last_used_at, :utc_datetime_usec

    timestamps()
  end

  @doc false
  # def changeset(credential, attrs) do
  #   credential
  #   |> cast(attrs, [:app_id, :public_key, :alg, :status, :expires_at, :last_used_at])
  #   |> validate_required([:app_id, :public_key, :alg, :status, :expires_at, :last_used_at])
  #   |> unique_constraint(:app_id)
  # end
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:app_id, :public_key, :alg, :status, :expires_at, :last_used_at])
    |> validate_required([:app_id, :public_key, :alg, :status])
    |> validate_length(:app_id, max: 100)
    |> unique_constraint(:app_id)
    |> validate_public_key_base64_32()
  end

  defp validate_public_key_base64_32(changeset) do
    with pk when is_binary(pk) <- get_change(changeset, :public_key),
         {:ok, bin} <- Base.url_decode64(pk, padding: false) || Base.decode64(pk),
         true <- byte_size(bin) == 32 do
      changeset
    else
      _ ->
        add_error(
          changeset,
          :public_key,
          "must be a base64/base64url-encoded 32-byte Ed25519 public key"
        )
    end
  end
end
