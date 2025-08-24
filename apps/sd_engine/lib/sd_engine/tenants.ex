defmodule SD.Tenants do
  @moduledoc """
  The Tenants context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.Tenants.Tenant
  alias SD.Tenants.TenantCalendar

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
  def get_tenant(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> SD.Repo.get(SD.Tenants.Tenant, uuid)
      :error -> nil
    end
  end

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

  # in SD.Tenants
  def create_tenant_user(attrs) do
    %SD.Tenants.TenantUser{}
    |> SD.Tenants.TenantUser.changeset(attrs)
    |> SD.Repo.insert()
    |> case do
      {:ok, tenant_user} ->
        {:ok, SD.Repo.preload(tenant_user, :user)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Fetch the user associated with a tenant.

  Given a `tenant_id` and a `user_id`, returns the user if that user
  is a member of the tenant. Returns `nil` if no such tenant_user exists.

  ## Examples

      iex> %TenantUser{} = SD.Tenants.get_tenant_user(tenant_id, user_id)

      iex> SD.Tenants.get_tenant_user("00000000-0000-0000-0000-000000000000", user_id)
      nil

  """
  def get_tenant_user(tenant_id, user_id) do
    with {:ok, _} <- Ecto.UUID.cast(tenant_id),
         {:ok, _} <- Ecto.UUID.cast(user_id) do
      from(tu in TenantUser,
        where: tu.tenant_id == ^tenant_id and tu.user_id == ^user_id,
        join: u in assoc(tu, :user),
        preload: [user: u]
      )
      |> Repo.one()
    else
      :error -> nil
    end
  end

  @doc """
  Lists tenant_users for a given tenant.

  Returns a list of `%SD.Tenants.TenantUser{}` structs with the associated
  `%SD.Users.User{}` preloaded in `:user`.

  Options:
    * `:limit`  – maximum number of records (default: 25)
    * `:offset` – number of records to skip (default: 0)
    * `:q`      – optional search string; matches `user.name` or `user.email` (ILIKE)

  Notes:
    * If `tenant_id` is not a valid UUID, an empty list `[]` is returned.
    * No 404 handling here; callers decide how to treat empty results.

  ## Examples

      iex> SD.Tenants.list_tenant_users(tenant_id)
      [%SD.Tenants.TenantUser{user: %SD.Users.User{}}, ...]

      iex> SD.Tenants.list_tenant_users(tenant_id, limit: 10, offset: 20, q: "alice")
      [%SD.Tenants.TenantUser{user: %SD.Users.User{}}, ...]
  """
  def list_tenant_users(tenant_id, opts \\ []) do
    case Ecto.UUID.cast(tenant_id) do
      :error ->
        []

      {:ok, _} ->
        limit = Keyword.get(opts, :limit, 25)
        offset = Keyword.get(opts, :offset, 0)
        q = Keyword.get(opts, :q)

        base_query(tenant_id)
        |> search_query(q)
        |> limit(^limit)
        |> offset(^offset)
        |> SD.Repo.all()
    end
  end

  defp base_query(tenant_id) do
    from tu in SD.Tenants.TenantUser,
      where: tu.tenant_id == ^tenant_id
  end

  defp search_query(base, q) do
    if is_binary(q) and q != "" do
      from tu in base,
        join: u in assoc(tu, :user),
        where: ilike(u.name, ^"%#{q}%") or ilike(u.email, ^"%#{q}%"),
        preload: [user: u]
    else
      from tu in base, preload: [:user]
    end
  end

  # Ecto.UUID.cast(tenant_id)

  @doc """
  Update a tenant user.

  ## Examples

      iex> update_tenant_user(tenant_user, %{role: "editor"})
      {:ok, %TenantUser{}}

      iex> update_tenant_user(tenant_user, %{role: nil})
      {:error, %Ecto.Changeset{}}
  """
  def update_tenant_user(%TenantUser{} = tenant_user, attrs) do
    tenant_user
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

  @doc """
  Convenience: list bare %Calendar{} for a tenant (via many_to_many preload).
  Useful when you don't need join rows or pagination.
  """
  def list_calendars(tenant_id) do
    case get_tenant(tenant_id) do
      nil ->
        []

      %Tenant{} = t ->
        t
        |> Repo.preload(:calendars)
        |> Map.get(:calendars, [])
    end
  end

  @doc """
  Creates a tenant_calendar link between a tenant and an existing calendar.

  Expects a map with:
    * "tenant_id"   – binary UUID
    * "calendar_id" – binary UUID

  On success returns {:ok, %TenantCalendar{calendar: %Calendar{}}} with :calendar preloaded.
  On failure returns {:error, %Ecto.Changeset{}}.

  Notes:
    * Relies on DB FKs/unique indexes for integrity (invalid/missing IDs → changeset errors).
  """
  def create_tenant_calendar(%{"tenant_id" => _tenant_id, "calendar_id" => _calendar_id} = attrs) do
    %TenantCalendar{}
    |> TenantCalendar.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, tenant_calendar} -> {:ok, Repo.preload(tenant_calendar, :calendar)}
      {:error, change_set} -> {:error, change_set}
    end
  end

  @doc """
  Fetch a single tenant_calendar by tenant_id and calendar_id.

  Returns the %TenantCalendar{} with :calendar preloaded, or nil if not found
  or if either id is not a valid UUID.
  """
  def get_tenant_calendar(tenant_id, calendar_id) do
    with {:ok, _} <- Ecto.UUID.cast(tenant_id),
         {:ok, _} <- Ecto.UUID.cast(calendar_id) do
      from(tc in TenantCalendar,
        where: tc.tenant_id == ^tenant_id and tc.calendar_id == ^calendar_id,
        join: c in assoc(tc, :calendar),
        preload: [calendar: c]
      )
      |> Repo.one()
    else
      :error -> nil
    end
  end

  @doc """
  List calendars linked to a tenant via tenant_calendars.

  Returns a list of %TenantCalendar{calendar: %Calendar{}} with :calendar preloaded.

  Options:
    * :limit  – default 25
    * :offset – default 0
    * :q      – optional search (ILIKE) on calendar.name

  If `tenant_id` is not a valid UUID, returns [].
  """
  def list_tenant_calendars(tenant_id, opts \\ []) do
    case Ecto.UUID.cast(tenant_id) do
      :error ->
        []

      {:ok, _} ->
        limit = Keyword.get(opts, :limit, 25)
        offset = Keyword.get(opts, :offset, 0)
        q = Keyword.get(opts, :q)

        base =
          from tc in TenantCalendar,
            where: tc.tenant_id == ^tenant_id

        query =
          if is_binary(q) and q != "" do
            from tc in base,
              join: c in assoc(tc, :calendar),
              where: ilike(c.name, ^"%#{q}%"),
              preload: [calendar: c]
          else
            from tc in base, preload: [:calendar]
          end

        query
        |> limit(^limit)
        |> offset(^offset)
        |> Repo.all()
    end
  end

  @doc """
  Delete a tenant_calendar link.

  Returns {:ok, %TenantCalendar{}} | {:error, %Ecto.Changeset{}}.
  """
  def delete_tenant_calendar(%TenantCalendar{} = tenant_calendar) do
    Repo.delete(tenant_calendar)
  end

  @doc """
  Return a changeset for tenant_calendar.
  """
  def change_tenant_calendar(%TenantCalendar{} = tenant_calendar, attrs \\ %{}) do
    TenantCalendar.changeset(tenant_calendar, attrs)
  end
end
