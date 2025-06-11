defmodule CLP.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias CLP.Repo

  alias CLP.Events.Event

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

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

  alias CLP.Events.EventUser

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
  Get an account user by ID.

  ## Examples

      iex> get_event_user!(123)
      %EventUser{}

      iex> get_event_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_event_user!(id), do: Repo.get!(EventUser, id)

  @doc """
  List all account users.

  ## Examples

      iex> list_event_users()
      [%EventUser{}, ...]
  """
  def list_event_users, do: Repo.all(EventUser)

  @doc """
  Update an account user.

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
  Delete an account user.

  ## Examples

      iex> delete_event_user(user)
      {:ok, %EventUser{}}
  """
  def delete_event_user(%EventUser{} = user), do: Repo.delete(user)

  @doc """
  Return an `%Ecto.Changeset{}` for tracking account user changes.
  """
  def change_event_user(%EventUser{} = user, attrs \\ %{}) do
    EventUser.changeset(user, attrs)
  end
end
