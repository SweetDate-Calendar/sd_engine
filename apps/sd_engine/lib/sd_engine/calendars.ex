defmodule SD.Calendars do
  @moduledoc """
  The SweetDate context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  # -------------- calendar users ---------------
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
