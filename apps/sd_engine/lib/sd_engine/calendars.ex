defmodule SD.Calendars do
  @moduledoc """
  The Calendars context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.Calendars.Calendar

  @doc """
  Returns the list of calendars.

  ## Examples

      iex> list_calendars()
      [%Calendar{}, ...]

  """
  def list_calendars do
    Repo.all(Calendar)
  end

  @doc """
  Gets a single calendar.

  Raises `Ecto.NoResultsError` if the Calendar does not exist.

  ## Examples

      iex> get_calendar(123)
      %Calendar{}

      iex> get_calendar(456)
      ** nil

  """
  def get_calendar(id), do: Repo.get(Calendar, id)

  @doc """
  Creates a calendar.

  ## Examples

      iex> create_calendar(%{field: value})
      {:ok, %Calendar{}}

      iex> create_calendar(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_calendar(attrs) do
    %Calendar{}
    |> Calendar.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a calendar.

  ## Examples

      iex> update_calendar(calendar, %{field: new_value})
      {:ok, %Calendar{}}

      iex> update_calendar(calendar, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_calendar(%Calendar{} = calendar, attrs) do
    calendar
    |> Calendar.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a calendar.

  ## Examples

      iex> delete_calendar(calendar)
      {:ok, %Calendar{}}

      iex> delete_calendar(calendar)
      {:error, %Ecto.Changeset{}}

  """
  def delete_calendar(%Calendar{} = calendar) do
    Repo.delete(calendar)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking calendar changes.

  ## Examples

      iex> change_calendar(calendar)
      %Ecto.Changeset{data: %Calendar{}}

  """
  def change_calendar(%Calendar{} = calendar, attrs \\ %{}) do
    Calendar.changeset(calendar, attrs)
  end

  alias SD.Calendars.CalendarUser

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
end
