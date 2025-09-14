defmodule SD.Tenants.TenantCalendar do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:tenant_id, :calendar_id]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tenant_calendars" do
    belongs_to :tenant, SD.Tenants.Tenant, type: :binary_id
    belongs_to :calendar, SD.SweetDate.Calendar, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(tenant_calendar, attrs) do
    tenant_calendar
    |> cast(attrs, [:tenant_id, :calendar_id])
    |> validate_required([:tenant_id, :calendar_id])
    |> validate_uuid(:tenant_id)
    |> validate_uuid(:calendar_id)
    |> unique_constraint([:tenant_id, :calendar_id])
  end

  defp validate_uuid(changeset, field) do
    case get_change(changeset, field) do
      nil ->
        changeset

      value ->
        case Ecto.UUID.cast(value) do
          {:ok, _uuid} -> changeset
          :error -> add_error(changeset, field, "is not a valid UUID")
        end
    end
  end
end
