defmodule SD.Repo.Migrations.CreateEventNotifications do
  use Ecto.Migration

  def change do
    create table(:event_invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :role, :string
      add :token, :string
      add :expires_at, :utc_datetime
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:event_invitations, [:event_id])
  end
end
