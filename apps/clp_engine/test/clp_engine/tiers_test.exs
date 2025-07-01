defmodule CLP.TiersTest do
  use CLP.DataCase

  alias CLP.Tiers

  describe "tiers" do
    alias CLP.Tiers.Tier

    import CLP.TiersFixtures

    @invalid_attrs %{name: nil}

    test "list_tiers/0 returns all tiers" do
      tier = tier_fixture()
      assert Tiers.list_tiers() == [tier]
    end

    test "get_tier!/1 returns the tier with given id" do
      tier = tier_fixture()
      assert Tiers.get_tier(tier.id) == tier
    end

    test "update_tier/2 with valid data updates the tier" do
      tier = tier_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Tier{} = tier} = Tiers.update_tier(tier, update_attrs)
      assert tier.name == "some updated name"
    end

    test "update_tier/2 with invalid data returns error changeset" do
      tier = tier_fixture()
      assert {:error, %Ecto.Changeset{}} = Tiers.update_tier(tier, @invalid_attrs)
      assert tier == Tiers.get_tier(tier.id)
    end

    test "delete_tier/1 deletes the tier" do
      tier = tier_fixture()
      assert {:ok, %Tier{}} = Tiers.delete_tier(tier)
      refute Tiers.get_tier(tier.id)
    end

    test "change_tier/1 returns a tier changeset" do
      tier = tier_fixture()
      assert %Ecto.Changeset{} = Tiers.change_tier(tier)
    end
  end
end
