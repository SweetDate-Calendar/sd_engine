defmodule SD.Calendars.Calendar do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :tenant_id, :color_theme, :visibility]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "calendars" do
    field :name, :string
    field :color_theme, :string

    field :visibility, Ecto.Enum,
      values: [:private, :shared, :public, :unlisted, :tenanted],
      default: :public

    belongs_to :tenant, SD.Tenants.Tenant, type: :binary_id

    many_to_many :users, SD.Accounts.User,
      join_through: "calendar_users",
      on_replace: :delete,
      join_keys: [calendar_id: :id, user_id: :id]

    has_many :events, SD.Events.Event,
      foreign_key: :calendar_id,
      references: :id

    timestamps()
  end

  @doc false
  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [:name, :color_theme, :visibility, :tenant_id])
    |> validate_required([:name, :visibility, :tenant_id])
  end
end
