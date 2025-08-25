defmodule SD.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  # -------------- event users ---------------

  alias SD.Accounts.EventUser

  @doc """
  Create event user.

  ## Examples

      iex> create_event_user(event_id, user_id, :organizer, :invited)
      {:ok, %EventUser{}}

      iex> create_event_user(invalid_id, user_id, nil, nil)
      {:error, %Ecto.Changeset{}}
  """
  def create_event_user(event_id, user_id, role, status) do
    %EventUser{}
    |> EventUser.changeset(%{event_id: event_id, user_id: user_id, role: role, status: status})
    |> Repo.insert()
  end

  @doc """
  Get an event_user by ID.

  ## Examples

      iex> get_event_user!(123)
      %EventUser{}

      iex> get_event_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_event_user!(id), do: Repo.get(EventUser, id)

  @doc """
  List all event_users.

  ## Examples

      iex> list_event_users()
      [%EventUser{}, ...]
  """
  def list_event_users, do: Repo.all(EventUser)

  @doc """
  Update an update_event_user.

  ## Examples

      iex> update_event_user(user, %{role: "admin"})
      {:ok, %EventUser{}}

      iex> update_event_user(user, %{role: nil})
      {:error, %Ecto.Changeset{}}
  """
  def update_event_user(%EventUser{} = user, attrs) do
    user
    |> EventUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete an event user.

  ## Examples

      iex> delete_event_user(user)
      {:ok, %EventUser{}}
  """
  def delete_event_user(%EventUser{} = user), do: Repo.delete(user)

  @doc """
  Return an `%Ecto.Changeset{}` for tracking event user changes.
  """
  def change_event_user(%EventUser{} = user, attrs \\ %{}) do
    EventUser.changeset(user, attrs)
  end

  # -------------- calendar users ---------------
  alias SD.Accounts.CalendarUser

  @doc """
    Create a calendar user.

    ## Examples

        iex> create_calendar_user(calendar_id, user_id, "owner")
        {:ok, %CalendarUser{}}

        iex> create_calendar_user(invalid_id, user_id, nil)
        {:error, %Ecto.Changeset{}}
  """
  def create_calendar_user(calendar_id, user_id, role) do
    %CalendarUser{}
    |> CalendarUser.changeset(%{calendar_id: calendar_id, user_id: user_id, role: role})
    |> Repo.insert()
  end

  @doc """
  Get a calendar user by ID.

  ## Examples

      iex> get_calendar_user!(123)
      %CalendarUser{}

      iex> get_calendar_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_calendar_user!(id), do: Repo.get(CalendarUser, id)

  @doc """
  List all calendar users.

  ## Examples

      iex> list_calendar_users()
      [%CalendarUser{}, ...]
  """
  def list_calendar_users, do: Repo.all(CalendarUser)

  @doc """
  Update a calendar user.

  ## Examples

      iex> update_calendar_user(user, %{role: "editor"})
      {:ok, %CalendarUser{}}

      iex> update_calendar_user(user, %{role: nil})
      {:error, %Ecto.Changeset{}}
  """
  def update_calendar_user(%CalendarUser{} = user, attrs) do
    user
    |> CalendarUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete a calendar user.

  ## Examples

      iex> delete_calendar_user(user)
      {:ok, %CalendarUser{}}
  """
  def delete_calendar_user(%CalendarUser{} = user), do: Repo.delete(user)

  @doc """
  Return an `%Ecto.Changeset{}` for tracking calendar user changes.
  """
  def change_calendar_user(%CalendarUser{} = user, attrs \\ %{}) do
    CalendarUser.changeset(user, attrs)
  end

  # --------------- tenant users ---------------

  alias SD.Accounts.TenantUser

  # in SD.Tenants
  def create_tenant_user(attrs) do
    %TenantUser{}
    |> TenantUser.changeset(attrs)
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

  Returns a list of `%SD.Accounts.TenantUser{}` structs with the associated
  `%SD.Accounts.User{}` preloaded in `:user`.

  Options:
    * `:limit`  – maximum number of records (default: 25)
    * `:offset` – number of records to skip (default: 0)
    * `:q`      – optional search string; matches `user.name` or `user.email` (ILIKE)

  Notes:
    * If `tenant_id` is not a valid UUID, an empty list `[]` is returned.
    * No 404 handling here; callers decide how to treat empty results.

  ## Examples

      iex> SD.Accounts.list_tenant_users(tenant_id)
      [%SD.Accounts.TenantUser{user: %SD.Accounts.User{}}, ...]

      iex> SD.Accounts.list_tenant_users(tenant_id, limit: 10, offset: 20, q: "alice")
      [%SD.Accounts.TenantUser{user: %SD.Accounts.User{}}, ...]
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
    from tu in SD.Accounts.TenantUser,
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
end
