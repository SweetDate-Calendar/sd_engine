defmodule SD.TenantsTest do
  use SD.DataCase

  alias SD.Accounts

  alias SD.{Tenants, Calendars}
  alias SD.Calendars.Calendar
  import SD.TenantsFixtures

  describe "add_calendar/2" do
    test "creates a calendar and associates it with the tenant" do
      tenant = tenant_fixture()

      params = %{
        name: "Team Calendar",
        color_theme: "blue",
        visibility: "public"
      }

      assert {:ok, %Calendar{} = calendar} = Tenants.add_calendar(tenant.id, params)

      # Calendar is persisted
      db_calendar = Calendars.get_calendar(calendar.id)
      assert db_calendar.name == "Team Calendar"
      assert db_calendar.color_theme == "blue"

      # Ensure the calendar is associated with the tenant
      calendars = SD.Tenants.list_calendars(tenant.id)

      assert Enum.any?(calendars, fn c ->
               c.id == calendar.id
             end)
    end

    test "returns an error when calendar params are invalid" do
      tenant = tenant_fixture()

      # Missing required fields
      params = %{name: nil}

      assert {:error, :calendar, %Ecto.Changeset{}, _changes_so_far} =
               Tenants.add_calendar(tenant.id, params)
    end
  end

  describe "tenants" do
    alias SD.Tenants.Tenant

    @invalid_attrs %{name: nil}

    test "list_tenants/0 returns all tenants" do
      tenant = tenant_fixture()
      results = Tenants.list_tenants()

      assert Enum.any?(results, fn t ->
               t.id == tenant.id and t.name == tenant.name
             end)
    end

    test "get_tenant!/1 returns the tenant with given id" do
      tenant = tenant_fixture()
      assert Tenants.get_tenant(tenant.id) == tenant
    end

    test "create_tenant/1 with valid data creates a tenant" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %SD.Tenants.Tenant{} = tenant} = Tenants.create_tenant(valid_attrs)
      assert tenant.name == "some name"
    end

    test "create_tenant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tenants.create_tenant(%{name: nil})
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

  # ───────────────────────────────────────────────────────────────────────────
  # tests for tenant users
  # ───────────────────────────────────────────────────────────────────────────
  alias SD.Accounts.TenantUser
  import SD.UsersFixtures

  describe "tenant users" do
    test "create_tenant_user/3 inserts a tenant_user with the given role" do
      tenant = tenant_fixture(%{name: "T1"})
      user = user_fixture(%{name: "Alice", email: "alice@example.com"})

      assert {:ok, %TenantUser{} = tenant_user} =
               Accounts.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => user.id,
                 "role" => "admin"
               })

      assert tenant_user.tenant_id == tenant.id
      assert tenant_user.user_id == user.id
      assert to_string(tenant_user.role) == "admin"
      assert tenant_user.inserted_at && tenant_user.updated_at
    end

    test "create_tenant_user/3 returns error changeset for invalid user" do
      tenant = tenant_fixture(%{name: "T2"})
      bad_user_id = Ecto.UUID.generate()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => bad_user_id,
                 "role" => "admin"
               })
    end

    test "add_tenant_user/2 defaults role to guest and preloads user" do
      tenant = tenant_fixture(%{name: "T3"})
      user = user_fixture(%{name: "Bob", email: "bob@example.com"})

      assert {:ok, %TenantUser{} = tu} =
               Accounts.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => user.id
               })

      # Default role
      assert to_string(tu.role) == "guest"

      # Preloaded user convenience
      assert tu.user
      assert tu.user.id == user.id
      assert tu.user.name == "Bob"
      assert tu.user.email == "bob@example.com"
    end

    test "create_tenant_user/1 accepts explicit role" do
      tenant = tenant_fixture(%{name: "T4"})
      user = user_fixture(%{name: "Carol", email: "carol@example.com"})

      assert {:ok, %TenantUser{} = tenant_user} =
               Accounts.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => user.id,
                 "role" => "owner"
               })

      assert to_string(tenant_user.role) == "owner"
      assert tenant_user.user && tenant_user.user_id == user.id
    end

    test "add_tenant_user/2 returns error changeset for invalid user_id" do
      tenant = tenant_fixture(%{name: "T5"})
      bad_id = Ecto.UUID.generate()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_tenant_user(%{"tenant_id" => tenant.id, "user_id" => bad_id})
    end

    test "list_tenant_users/2 returns tenant_users for the tenant (with optional q/limit/offset)" do
      tenant = tenant_fixture(%{name: "T6"})
      user_1 = user_fixture(%{name: "Alpha", email: "alpha@example.com"})
      user_2 = user_fixture(%{name: "Beta", email: "beta@example.com"})
      user_3 = user_fixture(%{name: "Gamma", email: "gamma@example.com"})

      Accounts.create_tenant_user(%{
        "tenant_id" => tenant.id,
        "user_id" => user_1.id,
        "role" => "guest"
      })

      Accounts.create_tenant_user(%{
        "tenant_id" => tenant.id,
        "user_id" => user_2.id,
        "role" => "admin"
      })

      Accounts.create_tenant_user(%{
        "tenant_id" => tenant.id,
        "user_id" => user_3.id,
        "role" => "owner"
      })

      # basic fetch
      items = Accounts.list_tenant_users(tenant.id)

      assert Enum.map(items, & &1.user_id) |> Enum.sort() ==
               Enum.map([user_1, user_2, user_3], & &1.id) |> Enum.sort()

      # # pagination
      # items2 = Accounts.list_tenant_users(tenant.id, limit: 2, offset: 1)
      # assert length(items2) == 2

      # # search by name/email
      # items3 = Accounts.list_tenant_users(tenant.id, q: "alpha")
      # assert Enum.any?(items3, &(&1.user_1.email == "alpha@example.com"))
    end
  end
end
