defmodule CLP.Repo.Migrations.CreateTiers do
  use Ecto.Migration

  def change do
    create table(:tiers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:tiers, [:account_id])
    create unique_index(:tiers, [:account_id, :name], name: :tiers_tier_id_name_index)
  end
end
