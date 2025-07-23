defmodule SD.Tenants do
  @moduledoc """
  The Tenants context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.Tenants.Tenant

  @doc """
  Returns the list of tenants.

  ## Examples

      iex> list_tenants()
      [%Tenant{}, ...]

  """
  def list_tenants(account_id) do
    from(t in Tenant,
      where: t.account_id == ^account_id,
      select: %{
        id: t.id,
        name: t.name
      }
    )
    |> Repo.all()
  end

  @doc """
  Gets a single tenant.

  Raises `Ecto.NoResultsError` if the Tenant does not exist.

  ## Examples

      iex> get_tenant(123)
      %Tenant{}

      iex> get_tenant(456)
      ** nil

  """
  def get_tenant(id), do: Repo.get(Tenant, id)

  @doc """
  Updates a tenant.

  ## Examples

      iex> update_tenant(tenant, %{field: new_value})
      {:ok, %Tenant{}}

      iex> update_tenant(tenant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tenant(%Tenant{} = tenant, attrs) do
    tenant
    |> Tenant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tenant.

  ## Examples

      iex> delete_tenant(tenant)
      {:ok, %Tenant{}}

      iex> delete_tenant(tenant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tenant(%Tenant{} = tenant) do
    Repo.delete(tenant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tenant changes.

  ## Examples

      iex> change_tenant(tenant)
      %Ecto.Changeset{data: %Tenant{}}

  """
  def change_tenant(%Tenant{} = tenant, attrs \\ %{}) do
    Tenant.changeset(tenant, attrs)
  end

  alias SD.Tenants.TenantUser

  @doc """
    Create a tenant user.

    ## Examples

        iex> create_tenant_user(tenant_id, user_id, "owner")
        {:ok, %TenantUser{}}

        iex> create_tenant_user(invalid_id, user_id, nil)
        {:error, %Ecto.Changeset{}}
  """
  def create_tenant_user(tenant_id, user_id, role) do
    %TenantUser{}
    |> TenantUser.changeset(%{tenant_id: tenant_id, user_id: user_id, role: role})
    |> Repo.insert()
  end

  @doc """
  Get a tenant user by ID.

  ## Examples

      iex> get_tenant_user!(123)
      %TenantUser{}

      iex> get_tenant_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_tenant_user!(id), do: Repo.get(TenantUser, id)

  @doc """
  List all tenant users.

  ## Examples

      iex> list_tenant_users()
      [%TenantUser{}, ...]
  """
  def list_tenant_users, do: Repo.all(TenantUser)

  @doc """
  Update a tenant user.

  ## Examples

      iex> update_tenant_user(user, %{role: "editor"})
      {:ok, %TenantUser{}}

      iex> update_tenant_user(user, %{role: nil})
      {:error, %Ecto.Changeset{}}
  """
  def update_tenant_user(%TenantUser{} = user, attrs) do
    user
    |> TenantUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete a tenant user.

  ## Examples

      iex> delete_tenant_user(user)
      {:ok, %TenantUser{}}
  """
  def delete_tenant_user(%TenantUser{} = user), do: Repo.delete(user)

  @doc """
  Return an `%Ecto.Changeset{}` for tracking tenant user changes.
  """
  def change_tenant_user(%TenantUser{} = user, attrs \\ %{}) do
    TenantUser.changeset(user, attrs)
  end
end
