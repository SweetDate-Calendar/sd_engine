defmodule SD.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  # -------------- users ---------------

  alias SD.Accounts.User

  @doc """
  Returns the list of users, ordered by `name` ascending.

  Supports pagination and optional name filtering.

  ## Options

    * `:limit` — maximum number of users to return (default: 25)
    * `:offset` — number of users to skip (default: 0)
    * `:q` — optional substring to search for in user names (case-insensitive)

  ## Examples

      iex> list_users()
      [%User{name: "Alice"}, %User{name: "Bob"}, ...]

      iex> list_users(limit: 10)
      [%User{}, ...]

      iex> list_users(limit: 10, offset: 20)
      [%User{}, ...]

      iex> list_users(q: "ali")
      [%User{name: "Alice"}]

  """
  def list_users(opts \\ []) do
    limit = Keyword.get(opts, :limit, 25)
    offset = Keyword.get(opts, :offset, 0)
    q = Keyword.get(opts, :q)

    base_query = from(u in User)

    query =
      if is_binary(q) and q != "" do
        from u in base_query,
          where: ilike(u.name, ^"%#{q}%"),
          order_by: [asc: u.name]
      else
        from u in base_query,
          order_by: [asc: u.name]
      end

    Repo.all(from u in query, limit: ^limit, offset: ^offset)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      ** nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user by email.

  returns nil if the User does not exist.

  ## Examples

      iex> get_user_by_email("some-email@example.com")
      %User{}

      iex> get_user("some-not-in-system-email@example.com")
      ** nil

  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Find or Create a user.

  ## Examples

      iex> get_or_create_user(%{field: value})
      {:ok, %User{}}

      iex> find_or_create_create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def get_or_create_user(attrs) do
    case get_user_by_email(attrs[:email]) do
      nil ->
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  # -------------- event users ---------------

  alias SD.Calendars.EventUser

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

  @doc """
  Delete only users whose name contains a CI seed marker like: [CI:abc123]

  Returns {:ok, count} | {:error, :seed_required}
  """
  def prune_test_data(seed) when is_binary(seed) and seed != "" do
    # match anywhere in the name
    pattern = "%" <> seed <> "%"

    {count, _} =
      from(u in User, where: ilike(u.name, ^pattern))
      |> Repo.delete_all()

    {:ok, count}
  end

  def prune_test_data(_), do: {:error, :seed_required}
end
