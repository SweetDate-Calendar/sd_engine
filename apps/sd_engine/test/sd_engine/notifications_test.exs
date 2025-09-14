defmodule SD.NotificationsTest do
  use SD.DataCase

  alias SD.Notifications

  describe "event_invitations" do
    alias SD.Notifications.Invitation

    import SD.NotificationsFixtures

    @invalid_attrs %{status: nil, token: nil, role: nil, expires_at: nil}

    test "list_event_invitations/0 returns all event_invitations" do
      invitation = invitation_fixture()
      assert Notifications.list_event_invitations(invitation.event_id) == [invitation]
    end

    test "get_invitation/1 returns the invitation with given id" do
      invitation = invitation_fixture()
      assert Notifications.get_invitation(invitation.id) == invitation
    end

    test "create_invitation/1 with valid data creates a invitation" do
      event = SD.CalendarsFixtures.event_fixture()

      valid_attrs = %{
        status: "pending",
        token: "some token",
        role: "organizer",
        expires_at: ~U[2025-08-26 11:42:00Z],
        event_id: event.id
      }

      assert {:ok, %Invitation{} = invitation} = Notifications.create_invitation(valid_attrs)
      assert invitation.status == :pending
      assert invitation.token == "some token"
      assert invitation.role == :organizer
      assert invitation.expires_at == ~U[2025-08-26 11:42:00Z]
    end

    test "create_invitation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_invitation(@invalid_attrs)
    end

    test "update_invitation/2 with valid data updates the invitation" do
      invitation = invitation_fixture()

      update_attrs = %{
        status: "accepted",
        token: "some updated token",
        role: "organizer",
        expires_at: ~U[2025-08-27 11:42:00Z]
      }

      assert {:ok, %Invitation{} = invitation} =
               Notifications.update_invitation(invitation, update_attrs)

      assert invitation.status == :accepted
      assert invitation.token == "some updated token"
      assert invitation.role == :organizer
      assert invitation.expires_at == ~U[2025-08-27 11:42:00Z]
    end

    test "update_invitation/2 with invalid data returns error changeset" do
      invitation = invitation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_invitation(invitation, @invalid_attrs)

      assert invitation == Notifications.get_invitation(invitation.id)
    end

    test "delete_invitation/1 deletes the invitation" do
      invitation = invitation_fixture()
      assert {:ok, %Invitation{}} = Notifications.delete_invitation(invitation)
      assert is_nil(Notifications.get_invitation(invitation.id))
    end

    test "change_invitation/1 returns a invitation changeset" do
      invitation = invitation_fixture()
      assert %Ecto.Changeset{} = Notifications.change_invitation(invitation)
    end
  end
end
