defmodule ClpTcp.Handlers.CalendarsTest do
  use ClpTcp.DataCase, async: false
  import CLP.CalendarsFixtures
  import CLP.AccountsFixtures
  import ClpTcp.TestHelper

  test "list all calendars" do
    account_id = account_fixture().id
    calendar_fixture(%{name: "One", account_id: account_id})

    calendar_fixture(%{name: "Two", account_id: account_id})

    response = tcp_send("CALENDARS.LIST|{}")
    assert response["status"] == "ok"
    assert length(response["calendars"]) >= 2
  end

  # test "CALENDARS.CREATE creates a new calendar with just a title" do
  #   payload = %{"name" => "RubyConf"}
  #   raw = "CALENDARS.CREATE|#{Jason.encode!(payload)}"
  #   response = tcp_send(raw)

  #   assert %{"status" => "ok", "id" => id} = response
  #   assert is_binary(id)
  # end

  # test "fetch calendar by id" do
  #   calendar = calendar_fixture(%{name: "Fetch Me"})

  #   payload = %{"id" => calendar.id}
  #   get_resp = tcp_send("CALENDARS.GET|" <> Jason.encode!(payload))

  #   assert get_resp["status"] == "ok"
  #   assert get_resp["calendar"]["name"] == "Fetch Me"
  # end

  # test "fetch calendar with invalid id returns error" do
  #   payload = %{"id" => "00000000-0000-0000-0000-000000000000"}

  #   response = tcp_send("CALENDARS.GET|" <> Jason.encode!(payload))

  #   assert response["status"] == "error"
  #   assert response["message"] == "not found"
  # end

  # test "update calendar name" do
  #   calendar = calendar_fixture(%{name: "Old Name"})

  #   payload = %{
  #     "id" => calendar.id,
  #     "name" => "New Name"
  #   }

  #   response = tcp_send("CALENDARS.UPDATE|" <> Jason.encode!(payload))
  #   assert response["status"] == "ok"
  #   assert response["calendar"]["name"] == "New Name"
  # end

  # test "delete calendar" do
  #   calendar = calendar_fixture()
  #   payload = %{"id" => calendar.id}

  #   response = tcp_send("CALENDARS.DELETE|" <> Jason.encode!(payload))
  #   assert response["status"] == "ok"

  #   # Ensure it's gone
  #   get_resp = tcp_send("CALENDARS.GET|" <> Jason.encode!(%{"id" => calendar.id}))
  #   assert get_resp["status"] == "error"
  # end
end
