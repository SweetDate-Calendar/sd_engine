defmodule SD.Tenants.TenantUserTest do
  use SD.DataCase, async: true

  alias SD.Tenants
  alias SD.Tenants.TenantUser
  alias SD.Repo

  import SD.TenantsFixtures
  import SD.AccountsFixtures

  describe "tenants_users join" do
    test "user can be added to tenant two times" do
      user = user_fixture()
      tenant = tenant_fixture()

      Tenants.create_tenant_user(tenant.id, user.id, :guest)

      assert {:error, _} =
               Tenants.create_tenant_user(tenant.id, user.id, :guest)
    end

    test "user can be added to tenant and accessed from both sides" do
      user = user_fixture()
      tenant = tenant_fixture()

      Tenants.create_tenant_user(tenant.id, user.id, :guest)

      user = Repo.preload(user, :tenants)

      assert Enum.any?(user.tenants, &(&1.id == tenant.id))

      tenant = Repo.preload(tenant, :users)
      assert Enum.any?(tenant.users, &(&1.id == user.id))
    end

    test "deleting user removes tenant_user row" do
      user = user_fixture()
      tenant = tenant_fixture()

      Tenants.create_tenant_user(tenant.id, user.id, :guest)

      Repo.delete!(user)

      refute Repo.exists?(
               from(au in TenantUser,
                 where: au.tenant_id == ^tenant.id and au.user_id == ^user.id
               )
             )
    end

    test "deleting tenant removes tenant_user row" do
      user = user_fixture()
      tenant = tenant_fixture()

      Tenants.create_tenant_user(tenant.id, user.id, :guest)

      Repo.delete!(tenant)

      refute Repo.exists?(
               from(au in TenantUser,
                 where: au.tenant_id == ^tenant.id and au.user_id == ^user.id
               )
             )
    end
  end
end
