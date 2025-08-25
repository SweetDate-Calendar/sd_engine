defmodule SD.Accounts.TenantUserTest do
  use SD.DataCase, async: true

  import Ecto.Query

  alias SD.Accounts
  alias SD.Accounts.TenantUser
  alias SD.Repo

  import SD.TenantsFixtures
  import SD.UsersFixtures

  describe "tenant_users join" do
    test "user cannot be added to the same tenant twice" do
      user = user_fixture()
      tenant = tenant_fixture()

      assert {:ok, %TenantUser{}} =
               Accounts.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => user.id,
                 "role" => "guest"
               })

      assert {:error, _changeset} =
               Accounts.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => user.id,
                 "role" => "guest"
               })
    end

    test "user can be added to tenant and accessed from both sides" do
      user = user_fixture()
      tenant = tenant_fixture()

      assert {:ok, %TenantUser{}} =
               Accounts.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => user.id,
                 "role" => "guest"
               })

      user = Repo.preload(user, :tenants)
      assert Enum.any?(user.tenants, &(&1.id == tenant.id))

      tenant = Repo.preload(tenant, :users)
      assert Enum.any?(tenant.users, &(&1.id == user.id))
    end

    test "deleting user removes tenant_user row" do
      user = user_fixture()
      tenant = tenant_fixture()

      assert {:ok, %TenantUser{}} =
               Accounts.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => user.id,
                 "role" => "guest"
               })

      Repo.delete!(user)

      refute Repo.exists?(
               from(tu in TenantUser,
                 where: tu.tenant_id == ^tenant.id and tu.user_id == ^user.id
               )
             )
    end

    test "deleting tenant removes tenant_user row" do
      user = user_fixture()
      tenant = tenant_fixture()

      assert {:ok, %TenantUser{}} =
               Accounts.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => user.id,
                 "role" => "guest"
               })

      Repo.delete!(tenant)

      refute Repo.exists?(
               from(tu in TenantUser,
                 where: tu.tenant_id == ^tenant.id and tu.user_id == ^user.id
               )
             )
    end
  end

  describe "scoped queries & helpers" do
    test "list_tenant_users/2 returns tenant_users for that tenant with limit/offset" do
      t1 = tenant_fixture(%{name: "Alpha"})
      t2 = tenant_fixture(%{name: "Beta"})
      u1 = user_fixture(%{name: "Ada", email: "ada@example.com"})
      u2 = user_fixture(%{name: "Bobby", email: "bobby@example.com"})
      u3 = user_fixture(%{name: "Cora", email: "cora@example.com"})

      {:ok, tu1} =
        Accounts.create_tenant_user(%{
          "tenant_id" => t1.id,
          "user_id" => u1.id,
          "role" => "guest"
        })

      {:ok, tu2} =
        Accounts.create_tenant_user(%{
          "tenant_id" => t1.id,
          "user_id" => u2.id,
          "role" => "admin"
        })

      {:ok, _tu3} =
        Accounts.create_tenant_user(%{
          "tenant_id" => t2.id,
          "user_id" => u3.id,
          "role" => "guest"
        })

      # No opts → default 25/0
      list_all = Accounts.list_tenant_users(t1.id)
      assert Enum.map(list_all, & &1.id) |> MapSet.new() == MapSet.new([tu1.id, tu2.id])

      # limit / offset
      list_page1 = Accounts.list_tenant_users(t1.id, limit: 1, offset: 0)
      list_page2 = Accounts.list_tenant_users(t1.id, limit: 5, offset: 1)
      assert length(list_page1) == 1
      assert length(list_page2) == 1
      refute hd(list_page1).id == hd(list_page2).id
    end

    test "list_tenant_users/2 supports simple q search over user name/email" do
      t = tenant_fixture(%{name: "Gamma"})
      _ = user_fixture(%{name: "Unrelated", email: "x@x.com"})

      u1 = user_fixture(%{name: "Alice Johnson", email: "alice@example.com"})
      u2 = user_fixture(%{name: "Bob Smith", email: "bob@example.com"})

      {:ok, _} =
        Accounts.create_tenant_user(%{
          "tenant_id" => t.id,
          "user_id" => u1.id,
          "role" => "guest"
        })

      {:ok, _} =
        Accounts.create_tenant_user(%{
          "tenant_id" => t.id,
          "user_id" => u2.id,
          "role" => "guest"
        })

      only_alice = Accounts.list_tenant_users(t.id, q: "alice")

      assert Enum.all?(only_alice, fn tenant_user ->
               tenant_user.user.email == "alice@example.com"
             end)
    end

    test "get_tenant_user/1 returns {:ok, user} or {:error, :not_found}" do
      tenant = tenant_fixture()
      user = user_fixture()

      # Create a tenant_user
      {:ok, _tenant_user} =
        Accounts.create_tenant_user(%{
          "tenant_id" => tenant.id,
          "user_id" => user.id,
          "role" => "guest"
        })

      # Success case: should return the tenant_user
      returned_tenant_user = Accounts.get_tenant_user(tenant.id, user.id)
      assert returned_tenant_user.user_id == user.id

      # Not found case
      assert is_nil(
               Accounts.get_tenant_user(
                 "00000000-0000-0000-0000-000000000000",
                 "00000000-0000-0000-0000-000000000000"
               )
             )
    end

    test "update_tenant_user/2 updates role" do
      t = tenant_fixture()
      u = user_fixture()

      {:ok, tenant_user} =
        Accounts.create_tenant_user(%{"tenant_id" => t.id, "user_id" => u.id, "role" => "guest"})

      assert {:ok, updated} =
               Accounts.update_tenant_user(tenant_user, %{
                 "role" => "admin"
               })

      assert updated.role == :admin
    end

    test "delete_tenant_user/1 removes tenant_user" do
      tenant = tenant_fixture()
      user = user_fixture()

      {:ok, tenant_user} =
        Accounts.create_tenant_user(%{
          "tenant_id" => tenant.id,
          "user_id" => user.id,
          "role" => "guest"
        })

      assert {:ok, _} = Accounts.delete_tenant_user(tenant_user)

      assert is_nil(Accounts.get_tenant_user(tenant.id, user.id))

      # refute Repo.exists?(from(x in TenantUser, where: x.id == ^tu.id))
    end
  end
end
