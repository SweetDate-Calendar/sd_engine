defmodule SD.Tenants.TenantCalendar do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tenant_calendars" do
    belongs_to :tenant, SD.Tenants.Tenant, type: :binary_id
    belongs_to :calendar, SD.Calendars.Calendar, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(tenant_calendar, attrs) do
    tenant_calendar
    |> cast(attrs, [:tenant_id, :calendar_id])
    |> validate_required([:tenant_id, :calendar_id])
    |> unique_constraint([:tenant_id, :calendar_id])
  end
end
