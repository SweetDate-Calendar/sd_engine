defmodule SD.TenantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SD.Tenants` context.
  """

  @doc """
  Generate a tenant.
  """
  def tenant_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{name: "some name#{System.unique_integer()}"})

    {:ok, tenant} = SD.Tenants.create_tenant(attrs)
    tenant
  end

  @doc """
  Generate a tenant_calendar join.
  If `:calendar_id` or `:tenant_id` are not provided, fixtures are used.
  """
  def tenant_user_fixture(attrs \\ %{}) do
    user_id =
      Map.get(attrs, :user_id) ||
        SD.AccountsFixtures.user_fixture().id

    tenant_id =
      Map.get(attrs, :tenant_id) ||
        SD.TenantsFixtures.tenant_fixture().id

    {:ok, tenant_user} =
      attrs
      |> Enum.into(%{
        tenant_id: tenant_id,
        user_id: user_id
      })
      |> SD.Tenants.create_tenant_user()

    tenant_user
  end
end
