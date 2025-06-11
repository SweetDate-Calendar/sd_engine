defmodule CLP.Repo.Migrations.CreateEventUsers do
  use Ecto.Migration

  def change do
    create table(:event_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string, default: "attendee"
      add :status, :string, default: "invited"
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:event_users, [:event_id, :user_id], name: :unique_event_user)

    create index(:event_users, [:event_id])
    create index(:event_users, [:user_id])
  end
end
