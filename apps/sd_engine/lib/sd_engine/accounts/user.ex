defmodule SD.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :email, :string

    has_many :tenant_users, SD.Accounts.TenantUser
    has_many :tenants, through: [:tenant_users, :tenant]

    has_many :calendar_users, SD.Accounts.CalendarUser
    has_many :calendars, through: [:calendar_users, :calendar]

    has_many :event_users, SD.Accounts.EventUser
    has_many :events, through: [:event_users, :event]

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
