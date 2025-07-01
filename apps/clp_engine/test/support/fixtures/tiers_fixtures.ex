defmodule CLP.TiersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CLP.Tiers` context.
  """

  @doc """
  Generate a tier.
  """
  def tier_fixture(attrs \\ %{}) do
    attrs =
      case Map.get(attrs, :account_id) || Map.get(attrs, "account_id") do
        nil ->
          %{id: account_id} = CLP.AccountsFixtures.account_fixture()
          Map.put(attrs, :account_id, account_id)

        _ ->
          attrs
      end

    attrs = Enum.into(attrs, %{name: "some name"})

    {:ok, tier} = CLP.Accounts.create_tier(attrs)
    tier
  end
end
