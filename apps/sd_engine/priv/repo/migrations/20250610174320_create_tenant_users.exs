defmodule SD.Repo.Migrations.CreateTenantUsers do
  use Ecto.Migration

  def change do
    create table(:tenant_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string
      add :tenant_id, references(:tenants, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:tenant_users, [:tenant_id, :user_id])
    create index(:tenant_users, [:tenant_id])
  end
end
