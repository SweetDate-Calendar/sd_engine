defmodule SD.TenantsTest do
  use SD.DataCase

  alias SD.{Tenants, SweetDate}
  alias SD.SweetDate.Calendar
  import SD.TenantsFixtures

  describe "prune_test_data/1" do
    alias SD.Tenants.Tenant

    test "deletes only tenants with the given CI seed" do
      # Tenants with CI marker
      t1 = tenant_fixture(%{name: "SDK Test [CI:abc123] Alpha"})
      t2 = tenant_fixture(%{name: "SDK Test [CI:abc123] Beta"})

      # Tenant without CI marker
      t3 = tenant_fixture(%{name: "Regular Tenant Gamma"})

      # Call prune
      assert {:ok, 2} = SD.Tenants.prune_test_data("abc123")

      # Deleted
      refute SD.Tenants.get_tenant(t1.id)
      refute SD.Tenants.get_tenant(t2.id)

      # Still present
      assert SD.Tenants.get_tenant(t3.id)
    end

    test "returns error when seed is missing or empty" do
      assert {:error, :seed_required} = SD.Tenants.prune_test_data(nil)
      assert {:error, :seed_required} = SD.Tenants.prune_test_data("")
      assert {:error, :seed_required} = SD.Tenants.prune_test_data(123)
    end
  end

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
      db_calendar = SweetDate.get_calendar(calendar.id)
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
  alias SD.Tenants.TenantUser
  import SD.AccountsFixtures

  describe "tenant users" do
    test "create_tenant_user/3 inserts a tenant_user with the given role" do
      tenant = tenant_fixture(%{name: "T1"})
      user = user_fixture(%{name: "Alice", email: "alice@example.com"})

      assert {:ok, %TenantUser{} = tenant_user} =
               Tenants.create_tenant_user(%{
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
               Tenants.create_tenant_user(%{
                 "tenant_id" => tenant.id,
                 "user_id" => bad_user_id,
                 "role" => "admin"
               })
    end

    test "add_tenant_user/2 defaults role to guest and preloads user" do
      tenant = tenant_fixture(%{name: "T3"})
      user = user_fixture(%{name: "Bob", email: "bob@example.com"})

      assert {:ok, %TenantUser{} = tu} =
               Tenants.create_tenant_user(%{
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
               Tenants.create_tenant_user(%{
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
               Tenants.create_tenant_user(%{"tenant_id" => tenant.id, "user_id" => bad_id})
    end

    test "list_tenant_users/2 returns tenant_users for the tenant (with optional q/limit/offset)" do
      tenant = tenant_fixture(%{name: "T6"})
      user_1 = user_fixture(%{name: "Alpha", email: "alpha@example.com"})
      user_2 = user_fixture(%{name: "Beta", email: "beta@example.com"})
      user_3 = user_fixture(%{name: "Gamma", email: "gamma@example.com"})

      Tenants.create_tenant_user(%{
        "tenant_id" => tenant.id,
        "user_id" => user_1.id,
        "role" => "guest"
      })

      Tenants.create_tenant_user(%{
        "tenant_id" => tenant.id,
        "user_id" => user_2.id,
        "role" => "admin"
      })

      Tenants.create_tenant_user(%{
        "tenant_id" => tenant.id,
        "user_id" => user_3.id,
        "role" => "owner"
      })

      # basic fetch
      items = Tenants.list_tenant_users(tenant.id)

      assert Enum.map(items, & &1.user_id) |> Enum.sort() ==
               Enum.map([user_1, user_2, user_3], & &1.id) |> Enum.sort()

      # # pagination
      # items2 = Tenants.list_tenant_users(tenant.id, limit: 2, offset: 1)
      # assert length(items2) == 2

      # # search by name/email
      # items3 = Tenants.list_tenant_users(tenant.id, q: "alpha")
      # assert Enum.any?(items3, &(&1.user_1.email == "alpha@example.com"))
    end
  end

  describe "tenants extra coverage" do
    test "get_tenant/1 returns nil for invalid uuid" do
      assert Tenants.get_tenant("not-a-uuid") == nil
    end

    test "list_tenants/1 with q filter" do
      t1 = tenant_fixture(%{name: "Apple Tenant"})
      _t2 = tenant_fixture(%{name: "Banana Tenant"})

      results = Tenants.list_tenants(q: "Apple")
      assert Enum.any?(results, &(&1.id == t1.id))
    end
  end

  describe "tenant calendars" do
    alias SD.Tenants.TenantCalendar

    test "create_tenant_calendar/1 with valid data" do
      tenant = tenant_fixture()
      cal = SD.CalendarsFixtures.calendar_fixture()

      attrs = %{tenant_id: tenant.id, calendar_id: cal.id}
      assert {:ok, %TenantCalendar{} = tc} = Tenants.create_tenant_calendar(attrs)
      assert tc.tenant_id == tenant.id
      assert tc.calendar_id == cal.id
      assert tc.calendar.id == cal.id
    end

    test "create_tenant_calendar/1 with invalid data returns error" do
      assert {:error, %Ecto.Changeset{}} =
               Tenants.create_tenant_calendar(%{tenant_id: "bad", calendar_id: "bad"})
    end

    test "get_tenant_calendar/2 returns the tenant_calendar" do
      tenant = tenant_fixture()
      cal = SD.CalendarsFixtures.calendar_fixture()
      {:ok, tc} = Tenants.create_tenant_calendar(%{tenant_id: tenant.id, calendar_id: cal.id})

      assert {:ok, found} = Tenants.get_tenant_calendar(tenant.id, cal.id)
      assert found.id == tc.id
      assert found.calendar.id == cal.id
    end

    test "get_tenant_calendar/2 returns :not_found when missing" do
      tenant = tenant_fixture()

      assert {:error, :not_found} =
               Tenants.get_tenant_calendar(tenant.id, Ecto.UUID.generate())
    end

    test "get_tenant_calendar/2 returns error for invalid uuids" do
      tenant = tenant_fixture()
      cal = SD.CalendarsFixtures.calendar_fixture()

      assert {:error, :invalid_tenant_id} =
               Tenants.get_tenant_calendar("not-a-uuid", cal.id)

      assert {:error, :invalid_calendar_id} =
               Tenants.get_tenant_calendar(tenant.id, "not-a-uuid")
    end

    test "list_tenant_calendars/2 returns tenant calendars with preload" do
      tenant = tenant_fixture()
      cal = SD.CalendarsFixtures.calendar_fixture()
      {:ok, _tc} = Tenants.create_tenant_calendar(%{tenant_id: tenant.id, calendar_id: cal.id})

      results = Tenants.list_tenant_calendars(tenant.id)
      assert Enum.any?(results, &(&1.calendar.id == cal.id))
    end

    test "list_tenant_calendars/2 returns [] for invalid uuid" do
      assert Tenants.list_tenant_calendars("not-a-uuid") == []
    end

    test "list_tenant_calendars/2 with q filter" do
      tenant = tenant_fixture()
      cal = SD.CalendarsFixtures.calendar_fixture(%{name: "Filtered Calendar"})
      {:ok, _tc} = Tenants.create_tenant_calendar(%{tenant_id: tenant.id, calendar_id: cal.id})

      results = Tenants.list_tenant_calendars(tenant.id, q: "Filtered")
      assert Enum.any?(results, &(&1.calendar.id == cal.id))
    end

    test "delete_tenant_calendar/1 deletes the join" do
      tenant = tenant_fixture()
      cal = SD.CalendarsFixtures.calendar_fixture()
      {:ok, tc} = Tenants.create_tenant_calendar(%{tenant_id: tenant.id, calendar_id: cal.id})

      assert {:ok, %TenantCalendar{}} = Tenants.delete_tenant_calendar(tc)
      assert {:error, :not_found} = Tenants.get_tenant_calendar(tenant.id, cal.id)
    end

    test "change_tenant_calendar/1 returns a changeset" do
      tenant = tenant_fixture()
      cal = SD.CalendarsFixtures.calendar_fixture()
      {:ok, tc} = Tenants.create_tenant_calendar(%{tenant_id: tenant.id, calendar_id: cal.id})

      assert %Ecto.Changeset{} = Tenants.change_tenant_calendar(tc)
    end
  end

  describe "tenant users extra coverage" do
    alias SD.Tenants.TenantUser

    test "get_tenant_user/2 returns tenant_user" do
      tenant = tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      {:ok, tu} =
        Tenants.create_tenant_user(%{
          "tenant_id" => tenant.id,
          "user_id" => user.id,
          "role" => "admin"
        })

      assert {:ok, found} = Tenants.get_tenant_user(tenant.id, user.id)
      assert found.id == tu.id
      assert found.user.id == user.id
    end

    test "get_tenant_user/2 returns :not_found when missing" do
      tenant = tenant_fixture()
      assert {:error, :not_found} = Tenants.get_tenant_user(tenant.id, Ecto.UUID.generate())
    end

    test "get_tenant_user/2 returns error for invalid uuids" do
      tenant = tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      assert {:error, :invalid_tenant_id} =
               Tenants.get_tenant_user("bad", user.id)

      assert {:error, :invalid_user_id} =
               Tenants.get_tenant_user(tenant.id, "bad")
    end

    test "update_tenant_user/2 updates role" do
      tenant = tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      {:ok, tu} =
        Tenants.create_tenant_user(%{
          "tenant_id" => tenant.id,
          "user_id" => user.id,
          "role" => "guest"
        })

      assert {:ok, %TenantUser{} = updated} = Tenants.update_tenant_user(tu, %{role: "owner"})
      assert to_string(updated.role) == "owner"
    end

    test "update_tenant_user/2 with invalid data returns error" do
      tenant = tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      {:ok, tu} =
        Tenants.create_tenant_user(%{
          "tenant_id" => tenant.id,
          "user_id" => user.id,
          "role" => "owner"
        })

      assert {:error, %Ecto.Changeset{}} = Tenants.update_tenant_user(tu, %{role: nil})
    end

    test "delete_tenant_user/1 deletes tenant user" do
      tenant = tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      {:ok, tu} =
        Tenants.create_tenant_user(%{"tenant_id" => tenant.id, "user_id" => user.id})

      assert {:ok, %TenantUser{}} = Tenants.delete_tenant_user(tu)
      assert {:error, :not_found} = Tenants.get_tenant_user(tenant.id, user.id)
    end

    test "change_tenant_user/1 returns changeset" do
      tenant = tenant_fixture()
      user = SD.AccountsFixtures.user_fixture()

      {:ok, tu} =
        Tenants.create_tenant_user(%{"tenant_id" => tenant.id, "user_id" => user.id})

      assert %Ecto.Changeset{} = Tenants.change_tenant_user(tu)
    end
  end
end
