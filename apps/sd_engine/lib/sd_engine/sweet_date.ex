defmodule SD.SweetDate do
  @moduledoc """
  The SweetDate context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.SweetDate.Calendar

  @doc """
  Returns the list of calendars, ordered by `name` ascending.

  Supports pagination via `:limit` and `:offset` options.

  ## Options

    * `:limit` — maximum number of calendars to return (default: 25)
    * `:offset` — number of calendars to skip (default: 0)

  ## Examples

      iex> list_calendars()
      [%Calendar{name: "Personal"}, %Calendar{name: "Work"}, ...]

      iex> list_calendars(limit: 10)
      [%Calendar{}, ...]

      iex> list_calendars(limit: 10, offset: 20)
      [%Calendar{}, ...]

  """
  def list_calendars(opts \\ []) do
    limit = Keyword.get(opts, :limit, 25)
    offset = Keyword.get(opts, :offset, 0)

    Calendar
    |> order_by([c], asc: c.name)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
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

  # ---------- events --------------

  alias SD.Calendars.Event

  @doc """
  Returns the list of events for the given calendar ID, ordered by `start_time` ascending.

  Supports pagination via `:limit` and `:offset` options.

  ## Options

    * `:limit` — maximum number of events to return (default: 25)
    * `:offset` — number of events to skip (default: 0)

  ## Examples

      iex> list_events(calendar_id)
      [%Event{}, ...]

      iex> list_events(calendar_id, limit: 10)
      [%Event{}, ...]

      iex> list_events(calendar_id, limit: 10, offset: 20)
      [%Event{}, ...]

  """
  def list_events(calendar_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 25)
    offset = Keyword.get(opts, :offset, 0)

    Event
    |> where([e], e.calendar_id == ^calendar_id)
    |> order_by([e], asc: e.start_time)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  @doc """
  Gets a single event.

  Return nil if the Event does not exist.

  ## Examples

      iex> get_event(123)
      %Event{}

      iex> get_event(456)
      ** nil

  """
  def get_event(id), do: Repo.get(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end
end
