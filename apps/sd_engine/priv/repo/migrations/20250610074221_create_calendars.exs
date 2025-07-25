defmodule SD.Repo.Migrations.CreateCalendars do
  use Ecto.Migration

  def change do
    create table(:calendars, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :color_theme, :string, default: "default"
      add :visibility, :string, default: "public"
      add :tenant_id, references(:tenants, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:calendars, [:tenant_id])
  end
end
