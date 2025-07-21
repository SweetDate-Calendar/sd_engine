defmodule SD.TenantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SD.Tenants` context.
  """

  @doc """
  Generate a tenant.
  """
  def tenant_fixture(attrs \\ %{}) do
    attrs =
      case Map.get(attrs, :account_id) || Map.get(attrs, "account_id") do
        nil ->
          %{id: account_id} = SD.AccountsFixtures.account_fixture()
          Map.put(attrs, :account_id, account_id)

        _ ->
          attrs
      end

    attrs = Enum.into(attrs, %{name: "some name#{System.unique_integer()}"})

    {:ok, tenant} = SD.Accounts.create_tenant(attrs)
    tenant
  end
end
