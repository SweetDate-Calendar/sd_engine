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
end
