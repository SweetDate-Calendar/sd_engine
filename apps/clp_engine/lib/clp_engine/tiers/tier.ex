defmodule CLP.Tiers.Tier do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tiers" do
    field :name, :string
    belongs_to :account, CLP.Accounts.Account, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(tier, attrs) do
    tier
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:account_id, :name])
  end
end
