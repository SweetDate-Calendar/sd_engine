defmodule SD.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:tenants, [:account_id])
    create unique_index(:tenants, [:account_id, :name], name: :tenants_tenant_id_name_index)
  end
end
