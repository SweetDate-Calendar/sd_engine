defmodule SD.TenantsTest do
  use SD.DataCase

  alias SD.Tenants

  alias SD.{Tenants, Calendars}
  alias SD.Calendars.Calendar
  alias SD.Tenants.TenantCalendar
  import SD.TenantsFixtures

  describe "add_calendar/2" do
    test "creates a calendar and associates it with the tenant" do
      # Create a tenant using your fixture or factory
      tenant = tenant_fixture()

      # Params for the new calendar
      params = %{
        name: "Team Calendar",
        color_theme: "blue",
        visibility: "public"
      }

      assert {:ok, %{calendar: %Calendar{} = calendar, tenant_calendar: %TenantCalendar{} = tc}} =
               Tenants.add_calendar(tenant.id, params)

      # # Calendar is persisted
      db_calendar = Calendars.get_calendar(calendar.id)
      assert db_calendar.name == "Team Calendar"
      assert db_calendar.color_theme == "blue"

      # # Join table is persisted
      assert tc.tenant_id == tenant.id
      assert tc.calendar_id == calendar.id
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
end
