defmodule CLP.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CLP.Accounts` context.
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
      |> CLP.Accounts.create_account()

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
        role: :admin
      })
      |> CLP.Accounts.create_user()

    user
  end
end
