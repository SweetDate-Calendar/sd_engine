defmodule SD.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  # alias SD.Accounts.User

  # @doc """
  # Returns the list of users, ordered by `email` ascending.

  # Supports pagination via `:limit` and `:offset` options.

  # ## Options

  #   * `:limit` — maximum number of users to return (default: 25)
  #   * `:offset` — number of users to skip (default: 0)

  # ## Examples

  #     iex> list_users()
  #     [%User{name: "Alpha"}, %User{name: "Beta"}, ...]

  #     iex> list_users(limit: 10)
  #     [%User{}, ...]

  #     iex> list_users(limit: 10, offset: 20)
  #     [%User{}, ...]

  # """
  # def list_users(opts \\ []) do
  #   limit = Keyword.get(opts, :limit, 25)
  #   offset = Keyword.get(opts, :offset, 0)

  #   User
  #   |> order_by([user], asc: user.name)
  #   |> limit(^limit)
  #   |> offset(^offset)
  #   |> Repo.all()
  # end

  # @doc """
  # Gets a single user.

  # Raises `Ecto.NoResultsError` if the User does not exist.

  # ## Examples

  #     iex> get_user(123)
  #     %User{}

  #     iex> get_user(456)
  #     ** nil

  # """
  # def get_user(id), do: Repo.get(User, id)

  # @doc """
  # Gets a single user by email.

  # returns nil if the User does not exist.

  # ## Examples

  #     iex> get_user_by_email("some-email@example.com")
  #     %User{}

  #     iex> get_user("some-not-in-system-email@example.com")
  #     ** nil

  # """
  # def get_user_by_email(email) do
  #   Repo.get_by(User, email: email)
  # end

  # @doc """
  # Creates a user.

  # ## Examples

  #     iex> create_user(%{field: value})
  #     {:ok, %User{}}

  #     iex> create_user(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_user(attrs) do
  #   %User{}
  #   |> User.changeset(attrs)
  #   |> Repo.insert()
  # end

  # @doc """
  # Find or Create a user.

  # ## Examples

  #     iex> get_or_create_user(%{field: value})
  #     {:ok, %User{}}

  #     iex> find_or_create_create_user(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def get_or_create_user(attrs) do
  #   case get_user_by_email(attrs[:email]) do
  #     nil ->
  #       %User{}
  #       |> User.changeset(attrs)
  #       |> Repo.insert()

  #     user ->
  #       {:ok, user}
  #   end
  # end

  # @doc """
  # Updates a user.

  # ## Examples

  #     iex> update_user(user, %{field: new_value})
  #     {:ok, %User{}}

  #     iex> update_user(user, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_user(%User{} = user, attrs) do
  #   user
  #   |> User.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a user.

  # ## Examples

  #     iex> delete_user(user)
  #     {:ok, %User{}}

  #     iex> delete_user(user)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_user(%User{} = user) do
  #   Repo.delete(user)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking user changes.

  # ## Examples

  #     iex> change_user(user)
  #     %Ecto.Changeset{data: %User{}}

  # """
  # def change_user(%User{} = user, attrs \\ %{}) do
  #   User.changeset(user, attrs)
  # end

  alias SD.SweetDate.Calendar

  @doc """
  Creates a calendar associated with a user.

  This function ensures that the new calendar is linked to the given user
  by inserting a record in the `user_calendars` join table.

  ## Examples

      iex> add_calendar(user_id, %{name: "Personal calendar"})
      {:ok, %SD.SweetDate.Calendar{}}

      iex> add_calendar(user_id, %{name: nil})
      {:error, :calendar, %Ecto.Changeset{}, _changes_so_far}


  """
  def add_calendar(user_id, params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:calendar, Calendar.changeset(%Calendar{}, params))
      |> Ecto.Multi.insert(:calendar_user, fn %{calendar: calendar} ->
        %SD.Calendars.CalendarUser{
          user_id: user_id,
          calendar_id: calendar.id
        }
      end)

    case Repo.transaction(multi) do
      {:ok, %{calendar: %SD.SweetDate.Calendar{} = calendar}} ->
        {:ok, calendar}

      {:error, step, value, changes} ->
        {:error, step, value, changes}
    end
  end
end
