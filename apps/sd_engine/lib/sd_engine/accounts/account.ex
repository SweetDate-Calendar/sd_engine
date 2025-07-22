defmodule SD.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, only: [:id, :name]}

  schema "accounts" do
    field :name, :string
    field :api_secret, :string

    has_many :tenants, SD.Tenants.Tenant

    many_to_many :users, SD.Accounts.User,
      join_through: "account_users",
      on_replace: :delete,
      join_keys: [account_id: :id, user_id: :id]

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:id, :name, :api_secret])
    |> validate_required([:name])
    |> maybe_put_api_secret()
  end

  defp maybe_put_api_secret(changeset) do
    case get_field(changeset, :api_secret) do
      nil ->
        put_change(changeset, :api_secret, generate_secret())

      _ ->
        changeset
    end
  end

  defp generate_secret do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64(padding: false)
  end
end
