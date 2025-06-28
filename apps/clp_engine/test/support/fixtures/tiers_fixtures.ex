defmodule CLP.TiersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CLP.Tiers` context.
  """

  @doc """
  Generate a tier.
  """
  def tier_fixture(attrs \\ %{}) do
    {:ok, tier} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> CLP.Tiers.create_tier()

    tier
  end
end
