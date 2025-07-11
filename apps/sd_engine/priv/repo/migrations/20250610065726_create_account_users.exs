defmodule SD.Repo.Migrations.CreateAccountUsers do
  use Ecto.Migration

  def change do
    create table(:account_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string, default: "guest"
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:account_users, [:account_id, :user_id])

    create index(:account_users, [:user_id])
    create index(:account_users, [:account_id])
  end
end
