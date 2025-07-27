defmodule SD.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SD.Users` context.
  """

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
      |> SD.Users.create_user()

    user
  end
end
