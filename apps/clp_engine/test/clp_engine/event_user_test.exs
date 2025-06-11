defmodule CLP.Events.EventUserTest do
  use CLP.DataCase, async: true

  alias CLP.Events.EventUser
  alias CLP.Events
  alias CLP.Repo

  import CLP.AccountsFixtures
  import CLP.EventsFixtures

  describe "event_users join" do
    setup do
      user = user_fixture()
      event = event_fixture()
      {:ok, event_user} = Events.create_event_user(event.id, user.id, :attendee, :invited)

      %{user: user, event: event, event_user: event_user}
    end

    test "user can't be added to an event two times", %{user: user, event: event} do
      assert {:error, _} =
               Events.create_event_user(event.id, user.id, :guest, :accepted)
    end

    test "user can be added to event and accessed from both sides", %{user: user, event: event} do
      user = Repo.preload(user, :events)
      assert Enum.any?(user.events, &(&1.id == event.id))

      event = Repo.preload(event, :users)
      assert Enum.any?(event.users, &(&1.id == user.id))
    end

    test "deleting user removes event_user row", %{user: user, event: event} do
      Repo.delete!(user)

      refute Repo.exists?(
               from(eu in EventUser,
                 where: eu.event_id == ^event.id and eu.user_id == ^user.id
               )
             )
    end

    test "deleting event removes event_user row", %{user: user, event: event} do
      Repo.delete!(event)

      refute Repo.exists?(
               from(eu in EventUser,
                 where: eu.event_id == ^event.id and eu.user_id == ^user.id
               )
             )
    end

    test "list_event_users/0 returns all event users", %{event_user: event_user} do
      result = Events.list_event_users()
      assert event_user in result
      assert is_list(result)
      assert Enum.all?(result, fn eu -> %EventUser{} = eu end)
    end

    test "update_event_user/2 with valid data updates the record", %{event_user: eu} do
      assert {:ok, updated} =
               Events.update_event_user(eu, %{role: :organizer, status: :accepted})

      assert updated.role == :organizer
      assert updated.status == :accepted
    end

    test "update_event_user/2 with invalid data returns error changeset", %{event_user: eu} do
      assert {:error, changeset} = Events.update_event_user(eu, %{role: nil})
      assert %Ecto.Changeset{} = changeset
      assert errors_on(changeset)[:role] != nil
    end
  end
end
