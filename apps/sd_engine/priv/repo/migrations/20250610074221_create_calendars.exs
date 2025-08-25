defmodule SD.Repo.Migrations.CreateSweetDate do
  use Ecto.Migration

  def change do
    create table(:calendars, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :color_theme, :string, default: "default"
      add :visibility, :string, default: "public"

      timestamps()
    end
  end
end
