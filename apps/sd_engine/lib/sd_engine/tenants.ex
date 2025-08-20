defmodule SD.Tenants do
  @moduledoc """
  The Tenants context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.Tenants.Tenant

  @doc """
  Returns the list of tenants, ordered by `name` ascending.

  Supports pagination via `:limit` and `:offset` options.

  ## Options

    * `:limit` — maximum number of tenants to return (default: 25)
    * `:offset` — number of tenants to skip (default: 0)

  ## Examples

      iex> list_tenants()
      [%Tenant{name: "Alpha"}, %Tenant{name: "Beta"}, ...]

      iex> list_tenants(limit: 10)
      [%Tenant{}, ...]

      iex> list_tenants(limit: 10, offset: 20)
      [%Tenant{}, ...]

  """
  def list_tenants(opts \\ []) do
    limit = Keyword.get(opts, :limit, 25)
    offset = Keyword.get(opts, :offset, 0)

    Tenant
    |> order_by([t], asc: t.name)
    |> limit(^limit)
    |> offset(^offset)
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
  Creates a tenant.

  ## Examples

      iex> create_tenant(%{field: value})
      {:ok, %Tenant{}}

      iex> create_tenant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tenant(attrs) do
    %Tenant{}
    |> Tenant.changeset(attrs)
    |> Repo.insert()
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
  def list_tenant_users do
    Repo.all(TenantUser)
  end

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

  @doc """
  Creates a calendar associated with a tenant.

  This function ensures that the new calendar is linked to the given tenant
  by inserting a record in the `tenant_calendars` join table.

  ## Examples

      iex> add_calendar(tenant_id, %{name: "Team calendar"})
      {:ok, %{calendar: %Calendar{}, tenant_calendar: %TenantCalendar{}}}

      iex> add_calendar(tenant_id, %{name: nil})
      {:error, :calendar, %Ecto.Changeset{}, _changes_so_far}

  ## Notes

  This function:

    * Inserts a new calendar with the given attributes.
    * Creates a join entry between the calendar and the tenant.
    * Runs inside a transaction (`Ecto.Multi`).
  """
  def add_calendar(tenant_id, params) do
    SD.Calendars.add_calendar_for(
      tenant_id,
      params,
      SD.Tenants.TenantCalendar,
      :tenant_id
    )
  end

  def list_calendars(tenant_id) do
    tenant =
      get_tenant(tenant_id)
      |> Repo.preload(:calendars)

    tenant.calendars
  end
end
