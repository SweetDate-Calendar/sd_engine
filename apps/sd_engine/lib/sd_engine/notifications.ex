defmodule SD.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.Notifications.Invitation

  @doc """
  Returns the list of event_invitations.

  ## Examples

      iex> list_event_invitations()
      [%Invitation{}, ...]

  """
  def list_event_invitations(event_id, opts \\ []) do
    case Ecto.UUID.cast(event_id) do
      :error ->
        []

      {:ok, _} ->
        limit = Keyword.get(opts, :limit, 25)
        offset = Keyword.get(opts, :offset, 0)

        from(invitation in Invitation,
          where: invitation.event_id == ^event_id
        )
        |> limit(^limit)
        |> offset(^offset)
        |> Repo.all()
    end

    # limit = Keyword.get(opts, :limit, 25)
    # offset = Keyword.get(opts, :offset, 0)

    # Invitations
    # |> order_by([invitation], asc: invitation.created_at)
    # |> limit(^limit)
    # |> offset(^offset)
    # |> Repo.all()
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
  def get_invitation(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> SD.Repo.get(SD.Notifications.Invitation, uuid)
      :error -> nil
    end
  end

  @doc """
  Creates a invitation.

  ## Examples

      iex> create_invitation(%{field: value})
      {:ok, %Invitation{}}

      iex> create_invitation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invitation(attrs) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invitation.

  ## Examples

      iex> update_invitation(invitation, %{field: new_value})
      {:ok, %Invitation{}}

      iex> update_invitation(invitation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invitation(%Invitation{} = invitation, attrs) do
    invitation
    |> Invitation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invitation.

  ## Examples

      iex> delete_invitation(invitation)
      {:ok, %Invitation{}}

      iex> delete_invitation(invitation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invitation(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invitation changes.

  ## Examples

      iex> change_invitation(invitation)
      %Ecto.Changeset{data: %Invitation{}}

  """
  def change_invitation(%Invitation{} = invitation, attrs \\ %{}) do
    Invitation.changeset(invitation, attrs)
  end
end
