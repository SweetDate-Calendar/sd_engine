defmodule SD.Tenants do
  @moduledoc """
  The Tenants context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.Tenants.Tenant
  alias SD.Users.User

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
  Adds an **existing user** to a tenant as a membership.

  Expects:

    * `tenant_id` — tenant UUID (binary)
    * `attrs` — map with:
      * `"user_id"` (required) — the user UUID to add
      * `"role"` (optional) — one of `"owner" | "admin" | "guest"` (defaults to `"guest"`)

  Returns:

    * `{:ok, %{tenant_user: %TenantUser{}, user: %User{}}}` on success
    * `{:error, :invalid}` when `"user_id"` is missing
    * `{:error, :not_found}` when tenant or user does not exist
    * `{:error, %Ecto.Changeset{}}` when membership creation fails
      (e.g., duplicate membership or invalid role)

  ## Examples

      iex> add_user(tenant_id, %{"user_id" => user_id, "role" => "admin"})
      {:ok, %{tenant_user: %TenantUser{}, user: %User{}}}

      iex> add_user(tenant_id, %{"user_id" => user_id})
      {:ok, %{tenant_user: %TenantUser{role: :guest}, user: %User{}}}

      iex> add_user(tenant_id, %{})
      {:error, :invalid}

      iex> add_user("00000000-0000-0000-0000-000000000000", %{"user_id" => user_id})
      {:error, :not_found}
  """
  def add_user(tenant_id, %{"user_id" => user_id} = attrs) when is_binary(tenant_id) do
    case get_tenant(tenant_id) do
      %Tenant{} ->
        case SD.Users.get_user(user_id) do
          %User{} = user ->
            role = Map.get(attrs, "role", "guest")

            case create_tenant_user(tenant_id, user.id, role) do
              {:ok, %TenantUser{} = tu} -> {:ok, %{tenant_user: tu, user: user}}
              {:error, %Ecto.Changeset{} = cs} -> {:error, cs}
            end

          _ ->
            # user not found
            {:error, :not_found}
        end

      _ ->
        # tenant not found
        {:error, :not_found}
    end
  end

  # No user_id provided
  def add_user(_tenant_id, _attrs), do: {:error, :invalid}

  @doc """
  Creates a tenant membership for an **existing** user.

  - `tenant_id` – UUID (binary)
  - `user_id` – UUID (binary)
  - `role` – string or atom (defaults handled by caller; typical values: "guest" | "admin" | "owner")

  Returns `{:ok, %TenantUser{}}` or `{:error, %Ecto.Changeset{}}`.
  """
  def create_tenant_user(tenant_id, user_id, role) do
    attrs = %{
      "tenant_id" => tenant_id,
      "user_id" => user_id,
      "role" => role
    }

    %TenantUser{}
    |> TenantUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Fetch the user associated with a tenant.

  Given a `tenant_id` and a `user_id`, returns the user if that user
  is a member of the tenant. Returns `nil` if no such membership exists.

  ## Examples

      iex> %TenantUser{} = SD.Tenants.get_tenant_user(tenant_id, user_id)

      iex> SD.Tenants.get_tenant_user("00000000-0000-0000-0000-000000000000", user_id)
      nil

  """
  def get_tenant_user(tenant_id, user_id) do
    from(tu in TenantUser,
      where: tu.tenant_id == ^tenant_id and tu.user_id == ^user_id,
      join: u in assoc(tu, :user)
    )
    |> Repo.one()
    |> Repo.preload(:user)
  end

  @doc """
  List tenant users for a given tenant.

  Supports `:limit`, `:offset`, and optional search `:q`.

  ## Examples

      iex> list_tenant_users(tenant_id)
      [%TenantUser{}, ...]

      iex> list_tenant_users(tenant_id, limit: 10, offset: 20, q: "alice")
      [%TenantUser{}, ...]
  """
  def list_tenant_users(tenant_id, opts \\ []) do
    import Ecto.Query

    limit = Keyword.get(opts, :limit, 25)
    offset = Keyword.get(opts, :offset, 0)
    q = Keyword.get(opts, :q)

    query =
      from tu in TenantUser,
        where: tu.tenant_id == ^tenant_id

    # optional search (adapt as needed)
    query =
      if q do
        from tu in query,
          join: u in assoc(tu, :user),
          where: ilike(u.name, ^"%#{q}%") or ilike(u.email, ^"%#{q}%"),
          preload: [user: u]
      else
        from tu in query, preload: [:user]
      end

    query
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
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
