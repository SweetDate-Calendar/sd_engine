defmodule CLP.Repo.Migrations.CreateCalendarUsers do
  use Ecto.Migration

  def change do
    create table(:calendar_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :calendar_id, references(:calendars, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:calendar_users, [:calendar_id, :user_id])

    create index(:calendar_users, [:user_id])
    create index(:calendar_users, [:calendar_id])
  end
end
