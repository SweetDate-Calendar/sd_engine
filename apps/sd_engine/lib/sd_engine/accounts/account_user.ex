defmodule SD.Accounts.AccountUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account_users" do
    field :role, Ecto.Enum, values: [:owner, :admin, :guest]

    belongs_to :account, SD.Accounts.Account, type: :binary_id
    belongs_to :user, SD.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(account_user, attrs) do
    account_user
    |> cast(attrs, [:user_id, :account_id, :role])
    |> validate_required([:user_id, :account_id, :role])
    |> unique_constraint([:account_id, :user_id], name: "account_users_account_id_user_id_index")
  end
end
