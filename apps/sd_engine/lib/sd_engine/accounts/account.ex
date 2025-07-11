defmodule SD.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, only: [:id, :name]}

  schema "accounts" do
    field :name, :string

    has_many :tiers, SD.Tiers.Tier

    many_to_many :users, SD.Accounts.User,
      join_through: "account_users",
      on_replace: :delete,
      join_keys: [account_id: :id, user_id: :id]

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
