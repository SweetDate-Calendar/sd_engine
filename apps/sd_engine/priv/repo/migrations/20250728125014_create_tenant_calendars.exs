defmodule SD.Repo.Migrations.CreateTenantSweetDate do
  use Ecto.Migration

  def change do
    create table(:tenant_calendars, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tenant_id, references(:tenants, on_delete: :delete_all, type: :binary_id), null: false

      add :calendar_id, references(:calendars, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps()
    end

    create unique_index(:tenant_calendars, [:tenant_id, :calendar_id])
  end
end
