defmodule SD.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string

    many_to_many :accounts, SD.Accounts.Account,
      join_through: "account_users",
      on_replace: :delete,
      join_keys: [user_id: :id, account_id: :id]

    many_to_many :tiers, SD.Tiers.Tier,
      join_through: "tier_users",
      on_replace: :delete,
      join_keys: [user_id: :id, tier_id: :id]

    many_to_many :calendars, SD.Calendars.Calendar,
      join_through: "calendar_users",
      on_replace: :delete,
      join_keys: [user_id: :id, calendar_id: :id]

    many_to_many :events, SD.Events.Event,
      join_through: "event_users",
      on_replace: :delete,
      join_keys: [user_id: :id, event_id: :id]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
