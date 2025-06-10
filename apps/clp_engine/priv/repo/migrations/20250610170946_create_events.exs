defmodule CLP.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string, default: "scheduled"
      add :name, :string
      add :description, :string
      add :color_theme, :string
      add :visibility, :string
      add :location, :string
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime
      add :recurrence_rule, :string
      add :all_day, :boolean, default: false, null: false
      add :calendar_id, references(:calendars, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:events, [:calendar_id])
  end
end
