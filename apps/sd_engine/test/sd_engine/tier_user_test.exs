defmodule SD.Tiers.TierUserTest do
  use SD.DataCase, async: true

  alias SD.Tiers
  alias SD.Tiers.TierUser
  alias SD.Repo

  import SD.TiersFixtures
  import SD.AccountsFixtures

  describe "tiers_users join" do
    test "user can be added to tier two times" do
      user = user_fixture()
      tier = tier_fixture()

      Tiers.create_tier_user(tier.id, user.id, :guest)

      assert {:error, _} =
               Tiers.create_tier_user(tier.id, user.id, :guest)
    end

    test "user can be added to tier and accessed from both sides" do
      user = user_fixture()
      tier = tier_fixture()

      Tiers.create_tier_user(tier.id, user.id, :guest)

      user = Repo.preload(user, :tiers)

      assert Enum.any?(user.tiers, &(&1.id == tier.id))

      tier = Repo.preload(tier, :users)
      assert Enum.any?(tier.users, &(&1.id == user.id))
    end

    test "deleting user removes tier_user row" do
      user = user_fixture()
      tier = tier_fixture()

      Tiers.create_tier_user(tier.id, user.id, :guest)

      Repo.delete!(user)

      refute Repo.exists?(
               from(au in TierUser,
                 where: au.tier_id == ^tier.id and au.user_id == ^user.id
               )
             )
    end

    test "deleting tier removes tier_user row" do
      user = user_fixture()
      tier = tier_fixture()

      Tiers.create_tier_user(tier.id, user.id, :guest)

      Repo.delete!(tier)

      refute Repo.exists?(
               from(au in TierUser,
                 where: au.tier_id == ^tier.id and au.user_id == ^user.id
               )
             )
    end
  end
end
