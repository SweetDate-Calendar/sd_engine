defmodule SD.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SD.Accounts` context.
  """

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> SD.Accounts.create_account()

    account
  end

  def create_authorized_account do
    account_id = Application.get_env(:sd_engine, :tcp)[:sweet_date_account_id]
    api_key = Application.get_env(:sd_engine, :tcp)[:sweet_access_api_key]

    attrs =
      %{
        id: account_id,
        api_secret: api_key,
        name: "Authorized account"
      }

    %SD.Accounts.Account{}
    |> SD.Accounts.Account.changeset(attrs)
    |> SD.Repo.insert()
  end

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "some name",
        email: "some-email#{System.unique_integer()}@example.com"
      })
      |> SD.Accounts.create_user()

    user
  end
end
