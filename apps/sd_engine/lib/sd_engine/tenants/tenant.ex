defmodule SD.Tenants.Tenant do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tenants" do
    field :name, :string

    many_to_many :calendars, SD.Calendars.Calendar,
      join_through: "tenant_calendars",
      on_replace: :delete

    many_to_many :users, SD.Accounts.User,
      join_through: "tenant_users",
      on_replace: :delete,
      join_keys: [tenant_id: :id, user_id: :id]

    timestamps()
  end

  @doc false
  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
