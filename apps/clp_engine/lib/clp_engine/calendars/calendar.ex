defmodule CLP.Calendars.Calendar do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :tier_id, :color_theme, :visibility]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "calendars" do
    field :name, :string
    field :color_theme, :string

    field :visibility, Ecto.Enum,
      values: [:private, :shared, :public, :unlisted, :tiered],
      default: :public

    belongs_to :tier, CLP.Tiers.Tier, type: :binary_id

    many_to_many :users, CLP.Accounts.User,
      join_through: "calendar_users",
      on_replace: :delete,
      join_keys: [calendar_id: :id, user_id: :id]

    has_many :events, CLP.Events.Event,
      foreign_key: :calendar_id,
      references: :id

    timestamps()
  end

  @doc false
  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [:name, :color_theme, :visibility, :tier_id])
    |> validate_required([:name, :visibility, :tier_id])
  end
end
