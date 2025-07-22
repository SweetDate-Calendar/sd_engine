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

  def authorized_account_fixture do
    account_id = Application.get_env(:sd_engine, :tcp)[:sweet_date_account_id]
    api_secret = Application.get_env(:sd_engine, :tcp)[:sweet_date_api_secret]

    attrs =
      %{
        id: account_id,
        api_secret: api_secret,
        name: "Authorized account"
      }

    {:ok, account} =
      %SD.Accounts.Account{}
      |> SD.Accounts.Account.changeset(attrs)
      |> SD.Repo.insert()

    account
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
