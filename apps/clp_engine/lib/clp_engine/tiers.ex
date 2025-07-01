defmodule CLP.Tiers do
  @moduledoc """
  The Tiers context.
  """

  import Ecto.Query, warn: false
  alias CLP.Repo

  alias CLP.Tiers.Tier

  @doc """
  Returns the list of tiers.

  ## Examples

      iex> list_tiers()
      [%Tier{}, ...]

  """
  def list_tiers do
    Repo.all(Tier)
  end

  @doc """
  Gets a single tier.

  Raises `Ecto.NoResultsError` if the Tier does not exist.

  ## Examples

      iex> get_tier(123)
      %Tier{}

      iex> get_tier(456)
      ** nil

  """
  def get_tier(id), do: Repo.get(Tier, id)

  @doc """
  Updates a tier.

  ## Examples

      iex> update_tier(tier, %{field: new_value})
      {:ok, %Tier{}}

      iex> update_tier(tier, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tier(%Tier{} = tier, attrs) do
    tier
    |> Tier.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tier.

  ## Examples

      iex> delete_tier(tier)
      {:ok, %Tier{}}

      iex> delete_tier(tier)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tier(%Tier{} = tier) do
    Repo.delete(tier)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tier changes.

  ## Examples

      iex> change_tier(tier)
      %Ecto.Changeset{data: %Tier{}}

  """
  def change_tier(%Tier{} = tier, attrs \\ %{}) do
    Tier.changeset(tier, attrs)
  end

  alias CLP.Tiers.TierUser

  @doc """
    Create a tier user.

    ## Examples

        iex> create_tier_user(tier_id, user_id, "owner")
        {:ok, %TierUser{}}

        iex> create_tier_user(invalid_id, user_id, nil)
        {:error, %Ecto.Changeset{}}
  """
  def create_tier_user(tier_id, user_id, role) do
    %TierUser{}
    |> TierUser.changeset(%{tier_id: tier_id, user_id: user_id, role: role})
    |> Repo.insert()
  end

  @doc """
  Get a tier user by ID.

  ## Examples

      iex> get_tier_user!(123)
      %TierUser{}

      iex> get_tier_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_tier_user!(id), do: Repo.get(TierUser, id)

  @doc """
  List all tier users.

  ## Examples

      iex> list_tier_users()
      [%TierUser{}, ...]
  """
  def list_tier_users, do: Repo.all(TierUser)

  @doc """
  Update a tier user.

  ## Examples

      iex> update_tier_user(user, %{role: "editor"})
      {:ok, %TierUser{}}

      iex> update_tier_user(user, %{role: nil})
      {:error, %Ecto.Changeset{}}
  """
  def update_tier_user(%TierUser{} = user, attrs) do
    user
    |> TierUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete a tier user.

  ## Examples

      iex> delete_tier_user(user)
      {:ok, %TierUser{}}
  """
  def delete_tier_user(%TierUser{} = user), do: Repo.delete(user)

  @doc """
  Return an `%Ecto.Changeset{}` for tracking tier user changes.
  """
  def change_tier_user(%TierUser{} = user, attrs \\ %{}) do
    TierUser.changeset(user, attrs)
  end
end
