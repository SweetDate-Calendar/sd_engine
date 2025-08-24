defmodule SD.Repo.Migrations.CreateTenantUsers do
  use Ecto.Migration

  def change do
    create table(:tenant_users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      # Ecto.Enum in the schema stores as string by default
      add :role, :string, null: false, default: "guest"

      add :tenant_id, references(:tenants, type: :binary_id, on_delete: :delete_all), null: false

      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:tenant_users, [:tenant_id, :user_id])
    create index(:tenant_users, [:tenant_id])
    create index(:tenant_users, [:user_id])
  end
end
