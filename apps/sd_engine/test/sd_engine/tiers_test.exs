defmodule SD.TenantsTest do
  use SD.DataCase

  alias SD.Tenants

  describe "tenants" do
    alias SD.Tenants.Tenant

    import SD.TenantsFixtures

    @invalid_attrs %{name: nil}

    setup do
      account = SD.AccountsFixtures.authorized_account_fixture()
      %{account: account}
    end

    test "list_tenants/0 returns all tenants", %{account: account} do
      tenant = tenant_fixture(%{acclunt_id: account.id})
      results = Tenants.list_tenants(tenant.account_id)

      assert Enum.any?(results, fn t ->
               t.id == tenant.id and t.name == tenant.name
             end)
    end

    test "get_tenant!/1 returns the tenant with given id" do
      tenant = tenant_fixture()
      assert Tenants.get_tenant(tenant.id) == tenant
    end

    test "update_tenant/2 with valid data updates the tenant" do
      tenant = tenant_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Tenant{} = tenant} = Tenants.update_tenant(tenant, update_attrs)
      assert tenant.name == "some updated name"
    end

    test "update_tenant/2 with invalid data returns error changeset" do
      tenant = tenant_fixture()
      assert {:error, %Ecto.Changeset{}} = Tenants.update_tenant(tenant, @invalid_attrs)
      assert tenant == Tenants.get_tenant(tenant.id)
    end

    test "delete_tenant/1 deletes the tenant" do
      tenant = tenant_fixture()
      assert {:ok, %Tenant{}} = Tenants.delete_tenant(tenant)
      refute Tenants.get_tenant(tenant.id)
    end

    test "change_tenant/1 returns a tenant changeset" do
      tenant = tenant_fixture()
      assert %Ecto.Changeset{} = Tenants.change_tenant(tenant)
    end
  end
end
