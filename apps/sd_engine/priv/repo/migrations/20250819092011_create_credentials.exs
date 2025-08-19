defmodule SD.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :app_id, :string
      add :public_key, :text
      add :alg, :string
      add :status, :string
      add :expires_at, :utc_datetime_usec
      add :last_used_at, :utc_datetime_usec

      timestamps()
    end

    create unique_index(:credentials, [:app_id])
  end
end
