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
  Fetch the user associated with a calendar.

  Given a `calendar_id` and a `user_id`, returns the user if that user
  is a member of the calendar. Returns `{:error, :not_found}` if no such
  calendar_user exists.

  ## Examples

      iex> SD.Calendars.get_calendar_user(calendar_id, user_id)
      {:ok, %CalendarUser{}}

      iex> SD.Calendars.get_calendar_user("00000000-0000-0000-0000-000000000000", user_id)
      {:error, :not_found}

      iex> SD.Calendars.get_calendar_user("not a uuid", user_id)
      {:error, :invalid_calendar_id}

      iex> SD.Calendars.get_calendar_user(calendar_id, "not a uuid")
      {:error, :invalid_user_id}
  """
  def get_calendar_user(calendar_id, user_id) do
    with {:ok, calendar_uuid} <-
           Ecto.UUID.cast(calendar_id) |> check_calendar_uuid(:invalid_calendar_id),
         {:ok, user_uuid} <-
           Ecto.UUID.cast(user_id) |> check_calendar_uuid(:invalid_user_id) do
      case Repo.one(
             from(cu in CalendarUser,
               where: cu.calendar_id == ^calendar_uuid and cu.user_id == ^user_uuid,
               join: u in assoc(cu, :user),
               preload: [user: u]
             )
           ) do
        nil -> {:error, :not_found}
        calendar_user -> {:ok, calendar_user}
      end
    end
  end

  defp check_calendar_uuid(:error, reason), do: {:error, reason}
  defp check_calendar_uuid({:ok, uuid}, _reason), do: {:ok, uuid}

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
  def delete_calendar_user(calendar_user) do
    Repo.delete(calendar_user)
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
  Fetch the user associated with an event.

  Given an `event_id` and a `user_id`, returns the user if that user
  is a member of the event. Returns `{:error, :not_found}` if no such
  event_user exists.

  ## Examples

      iex> SD.Calendars.get_event_user(event_id, user_id)
      {:ok, %EventUser{}}

      iex> SD.Calendars.get_event_user("00000000-0000-0000-0000-000000000000", user_id)
      {:error, :not_found}

      iex> SD.Calendars.get_event_user("not a uuid", user_id)
      {:error, :invalid_event_id}

      iex> SD.Calendars.get_event_user(event_id, "not a uuid")
      {:error, :invalid_user_id}
  """
  def get_event_user(event_id, user_id) do
    with {:ok, event_uuid} <- Ecto.UUID.cast(event_id) |> check_event_uuid(:invalid_event_id),
         {:ok, user_uuid} <- Ecto.UUID.cast(user_id) |> check_event_uuid(:invalid_user_id) do
      case Repo.one(
             from(eu in EventUser,
               where: eu.event_id == ^event_uuid and eu.user_id == ^user_uuid,
               join: u in assoc(eu, :user),
               preload: [user: u]
             )
           ) do
        nil -> {:error, :not_found}
        event_user -> {:ok, event_user}
      end
    end
  end

  defp check_event_uuid(:error, reason), do: {:error, reason}
  defp check_event_uuid({:ok, uuid}, _reason), do: {:ok, uuid}

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
  Deletes a event_user.

  This function deletes a `EventUser` association from the join table between users and events.

  ## Examples

      iex> delete_event_user("event-id", "user-id")
      {:ok, %CalendarUser{}}

      iex> delete_event_user_by_pair("missing-calendar", "missing-user")
      {:error, :not_found}
  """
  def delete_event_user(event_user) do
    Repo.delete(event_user)
  end

  @doc """
  Return an `%Ecto.Changeset{}` for tracking event user changes.
  """
  def change_event_user(%EventUser{} = user, attrs \\ %{}) do
    EventUser.changeset(user, attrs)
  end
end
