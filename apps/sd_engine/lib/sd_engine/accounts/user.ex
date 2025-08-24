defmodule SD.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :email, :string

    many_to_many :tenants, SD.Tenants.Tenant,
      join_through: "tenant_users",
      on_replace: :delete,
      join_keys: [user_id: :id, tenant_id: :id]

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
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> update_change(:email, fn e -> e |> String.trim() |> String.downcase() end)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, SD.Repo)
    |> unique_constraint(:email)
  end
end
