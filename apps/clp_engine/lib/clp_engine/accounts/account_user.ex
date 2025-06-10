defmodule CLP.Accounts.AccountUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_users" do
    belongs_to :account, CLP.Accounts.Account, type: :binary_id
    belongs_to :user, CLP.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(account_user, attrs) do
    account_user
    |> cast(attrs, [:user_id, :account_id])
    |> validate_required([:user_id, :account_id])
  end
end
