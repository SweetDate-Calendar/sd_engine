defmodule SD.Tenants.TenantUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tenant_users" do
    field :role, Ecto.Enum,
      values: [:owner, :admin, :guest],
      default: :guest

    belongs_to :tenant, SD.Tenants.Tenant, type: :binary_id
    belongs_to :user, SD.Users.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(tenant_user, attrs) do
    tenant_user
    |> cast(attrs, [:user_id, :tenant_id, :role])
    |> validate_required([:user_id, :tenant_id, :role])
    |> validate_uuid(:tenant_id)
    |> validate_uuid(:user_id)
    |> foreign_key_constraint(:tenant_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:tenant_id, :user_id])
  end

  # Helper to check UUID format
  defp validate_uuid(changeset, field) do
    case get_field(changeset, field) do
      nil ->
        changeset

      value when is_binary(value) ->
        case Ecto.UUID.cast(value) do
          {:ok, _} -> changeset
          :error -> add_error(changeset, field, "is not a valid UUID")
        end

      _ ->
        add_error(changeset, field, "is not a valid UUID")
    end
  end
end
