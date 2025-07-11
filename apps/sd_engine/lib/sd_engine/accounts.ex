defmodule SD.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.Accounts.Account

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account(123)
      %Account{}

      iex> get_account(456)
      ** nil

  """
  def get_account(id), do: Repo.get(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  alias SD.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
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

  alias SD.Accounts.AccountUser

  @doc """
  Create account user.

  ## Examples

      iex> create_account_user(account_id, user_id, "owner")
      {:ok, %AccountUser{}}

      iex> create_account_user(invalid_id, user_id, nil)
      {:error, %Ecto.Changeset{}}
  """
  def create_account_user(account_id, user_id, role) do
    %AccountUser{}
    |> AccountUser.changeset(%{account_id: account_id, user_id: user_id, role: role})
    |> Repo.insert()
  end

  @doc """
  Get an account user by ID.

  ## Examples

      iex> get_account_user!(123)
      %AccountUser{}

      iex> get_account_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_account_user!(id), do: Repo.get(AccountUser, id)

  @doc """
  List all account users.

  ## Examples

      iex> list_account_users()
      [%AccountUser{}, ...]
  """
  def list_account_users, do: Repo.all(AccountUser)

  @doc """
  Update an account user.

  ## Examples

      iex> update_account_user(user, %{role: "admin"})
      {:ok, %AccountUser{}}

      iex> update_account_user(user, %{role: nil})
      {:error, %Ecto.Changeset{}}
  """
  def update_account_user(%AccountUser{} = user, attrs) do
    user
    |> AccountUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete an account user.

  ## Examples

      iex> delete_account_user(user)
      {:ok, %AccountUser{}}
  """
  def delete_account_user(%AccountUser{} = user), do: Repo.delete(user)

  @doc """
  Return an `%Ecto.Changeset{}` for tracking account user changes.
  """
  def change_account_user(%AccountUser{} = user, attrs \\ %{}) do
    AccountUser.changeset(user, attrs)
  end

  alias SD.Tiers.Tier

  @doc """
  Creates a tier.

  ## Examples

      iex> create_tier(%{field: value})
      {:ok, %Tier{}}

      iex> create_tier(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tier(attrs) do
    %Tier{}
    |> Tier.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  List calendars

  ## Example
      iex> list_calendars(account)
      [%Calendar{}, ...]

  """
  def list_calendars(%SD.Accounts.Account{id: account_id}) do
    from(c in SD.Calendars.Calendar,
      join: t in SD.Tiers.Tier,
      on: c.tier_id == t.id,
      where: t.account_id == ^account_id,
      select: c
    )
    |> Repo.all()
  end
end
