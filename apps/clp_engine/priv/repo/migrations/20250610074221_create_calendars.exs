defmodule CLP.Repo.Migrations.CreateCalendars do
  use Ecto.Migration

  def change do
    create table(:calendars, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :color_theme, :string
      add :visibility, :string
      add :account_id, references(:accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:calendars, [:account_id])
  end
end
