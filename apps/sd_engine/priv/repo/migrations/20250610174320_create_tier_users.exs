defmodule SD.Repo.Migrations.CreateTierUsers do
  use Ecto.Migration

  def change do
    create table(:tier_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string
      add :tier_id, references(:tiers, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:tier_users, [:tier_id, :user_id])
    create index(:tier_users, [:tier_id])
  end
end
