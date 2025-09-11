defmodule SD.Calendars do
  @moduledoc """
  The SweetDate context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.Calendars.CalendarUser

  @doc """
    Create a calendar user.

    ## Examples

        iex> create_calendar_user(calendar_id, user_id, "owner")
        {:ok, %CalendarUser{}}

        iex> create_calendar_user(invalid_id, user_id, nil)
        {:error, %Ecto.Changeset{}}
  """
  def create_calendar_user(params) do
    %CalendarUser{}
    |> CalendarUser.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Fetch one user associated with a calendar.

  Given a `calendar_id` and a `user_id`, returns the user if that user
  is a member of the calendar. Returns `error` if no such calendar_user exists.

  ## Examples

      iex>  SD.Calendars.get_calendar_user(calendar_id, user_id)
      {:ok, %CalendarUser{}}

      iex> SD.Calendars.get_calendar_user("00000000-0000-0000-0000-000000000000", user_id)
      {:error, :not_found}

      iex> SD.Calendars.get_calendar_user("not a uuid", user_id)
      {:error, :invalid_id}

  """
  def get_calendar_user(attrs) when is_map(attrs) do
    calendar_id_raw = Map.get(attrs, "calendar_id") || Map.get(attrs, :calendar_id)
    user_id_raw = Map.get(attrs, "id") || Map.get(attrs, :id)

    with {:ok, calendar_id} <- Ecto.UUID.cast(calendar_id_raw),
         {:ok, user_id} <- Ecto.UUID.cast(user_id_raw),
         {:ok, calendar_user} <- do_get_calendar_user(calendar_id, user_id) do
      {:ok, calendar_user}
    else
      # one of the UUID casts failed
      :error -> {:error, :invalid_id}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp do_get_calendar_user(calendar_id, user_id) do
    calendar_user =
      from(cu in CalendarUser,
        where: cu.calendar_id == ^calendar_id and cu.user_id == ^user_id,
        preload: [:user]
      )
      |> Repo.one()

    case calendar_user do
      %CalendarUser{} = calendar_user -> {:ok, calendar_user}
      _ -> {:error, :not_found}
    end
  end

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
  Deletes a calendar user join.

  This function deletes a `CalendarUser` association from the join table between users and calendars.

  ## Examples

      iex> delete_calendar_user("calendar-id", "user-id")
      {:ok, %CalendarUser{}}

      iex> delete_calendar_user_by_pair("missing-calendar", "missing-user")
      {:error, :not_found}
  """
  def delete_calendar_user(calendar_id, user_id) do
    case Repo.get_by(CalendarUser, calendar_id: calendar_id, user_id: user_id) do
      nil -> {:error, :not_found}
      calendar_user -> Repo.delete(calendar_user)
    end
  end

  @doc """
  Return an `%Ecto.Changeset{}` for tracking calendar user changes.
  """
  def change_calendar_user(%CalendarUser{} = user, attrs \\ %{}) do
    CalendarUser.changeset(user, attrs)
  end

  # -------------- event users ---------------

  alias SD.Calendars.EventUser

  @doc """
  Creates an event user.

  ## Examples

      iex> create_event_user(%{
        event_id: "event-id-123",
        user_id: "user-id-456",
        role: :owner,
        status: :confirmed
      })
      {:ok, %EventUser{}}

      iex> create_event_user(%{event_id: nil, user_id: nil})
      {:error, %Ecto.Changeset{}}
  """
  def create_event_user(params) do
    %EventUser{}
    |> EventUser.changeset(params)
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
end
