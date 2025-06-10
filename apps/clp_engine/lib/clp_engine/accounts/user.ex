defmodule CLP.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string

    many_to_many :accounts, CLP.Accounts.Account,
      join_through: "accounts_users",
      on_replace: :delete,
      join_keys: [user_id: :id, account_id: :id]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
