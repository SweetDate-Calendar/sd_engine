defmodule SD.Tiers.Tier do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :account_id, :name]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tiers" do
    field :name, :string
    belongs_to :account, SD.Accounts.Account, type: :binary_id
    has_many :calendars, SD.Calendars.Calendar

    many_to_many :users, SD.Accounts.User,
      join_through: "tier_users",
      on_replace: :delete,
      join_keys: [tier_id: :id, user_id: :id]

    timestamps()
  end

  @doc false
  def changeset(tier, attrs) do
    tier
    |> cast(attrs, [:name, :account_id])
    |> validate_required([:name, :account_id])
    |> unique_constraint([:account_id, :name], name: :tiers_tier_id_name_index)
  end
end
