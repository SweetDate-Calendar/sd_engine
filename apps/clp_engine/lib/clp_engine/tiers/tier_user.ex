defmodule CLP.Tiers.TierUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tier_users" do
    field :role, Ecto.Enum,
      values: [:owner, :admin, :guest],
      default: :admin

    belongs_to :tier, CLP.Tiers.Tier, type: :binary_id
    belongs_to :user, CLP.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(tier_user, attrs) do
    tier_user
    |> cast(attrs, [:user_id, :tier_id, :role])
    |> validate_required([:user_id, :tier_id, :role])
    |> unique_constraint([:tier_id, :user_id])
  end
end
