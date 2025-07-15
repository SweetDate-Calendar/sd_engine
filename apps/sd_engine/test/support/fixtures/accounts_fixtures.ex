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
