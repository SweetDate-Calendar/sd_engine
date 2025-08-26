defmodule SD.SweetDate.Calendar do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :color_theme, :visibility]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "calendars" do
    field :name, :string
    field :color_theme, :string

    field :visibility, Ecto.Enum,
      values: [:private, :shared, :public, :unlisted, :tenanted, :global],
      default: :public

    many_to_many :tenants, SD.Tenants.Tenant,
      join_through: "tenant_calendars",
      on_replace: :delete

    many_to_many :users, SD.Accounts.User,
      join_through: "calendar_users",
      on_replace: :delete,
      join_keys: [calendar_id: :id, user_id: :id]

    has_many :events, SD.SweetDate.Event,
      foreign_key: :calendar_id,
      references: :id

    timestamps()
  end

  @doc false
  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [:name, :color_theme, :visibility])
    |> validate_required([:name, :visibility])
  end
end
