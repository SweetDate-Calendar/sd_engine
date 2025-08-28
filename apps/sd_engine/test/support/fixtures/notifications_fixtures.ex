defmodule SD.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SD.Notifications` context.
  """

  @doc """
  Generate a invitation.
  """
  def invitation_fixture(attrs \\ %{}) do
    event = attrs[:event] || SD.SweetDateFixtures.event_fixture()

    {:ok, invitation} =
      attrs
      |> Enum.into(%{
        event_id: event.id,
        expires_at: ~U[2025-08-26 11:42:00Z],
        role: "organizer",
        status: "pending",
        token: "some token"
      })
      |> SD.Notifications.create_invitation()

    invitation
  end
end
