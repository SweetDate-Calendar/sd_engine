defmodule CLP.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    field :name, :string

    many_to_many :users, CLP.Accounts.User,
      join_through: "account_users",
      on_replace: :delete,
      join_keys: [account_id: :id, user_id: :id]

    has_many :calendars, CLP.Calendars.Calendar,
      foreign_key: :account_id,
      on_delete: :delete_all,
      references: :id

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
