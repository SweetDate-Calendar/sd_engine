defmodule CLP.Accounts.AccountUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_users" do

    field :user_id, :binary_id
    field :account_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(account_user, attrs) do
    account_user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
