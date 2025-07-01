defmodule ClpTcp.Handlers.TiersTest do
  use ClpTcp.DataCase, async: false
  import CLP.TiersFixtures
  alias ClpTcp.TestHelper

  test "list all tiers" do
    tier_fixture(%{name: "One"})
    tier_fixture(%{name: "Two"})

    response = TestHelper.tcp_send("TIERS.LIST|{}")
    assert response["status"] == "ok"
    assert length(response["tiers"]) >= 2
  end

  test "ACCOUNDS.CREATE creates a new tier with just a title" do
    account = CLP.AccountsFixtures.account_fixture()
    payload = %{"name" => "RubyConf", account_id: account.id}
    raw = "TIERS.CREATE|#{Jason.encode!(payload)}"
    response = TestHelper.tcp_send(raw)

    assert %{"status" => "ok", "id" => id} = response
    assert is_binary(id)
  end

  test "fetch tier by id" do
    tier = tier_fixture(%{name: "Fetch Me"})

    payload = %{"id" => tier.id}
    get_resp = TestHelper.tcp_send("TIERS.GET|" <> Jason.encode!(payload))

    assert get_resp["status"] == "ok"
    assert get_resp["tier"]["name"] == "Fetch Me"
  end

  test "fetch tier with invalid id returns error" do
    payload = %{"id" => "00000000-0000-0000-0000-000000000000"}

    response = TestHelper.tcp_send("TIERS.GET|" <> Jason.encode!(payload))

    assert response["status"] == "error"
    assert response["message"] == "not found"
  end

  test "update tier name" do
    tier = tier_fixture(%{name: "Old Name"})

    payload = %{
      "id" => tier.id,
      "name" => "New Name"
    }

    response = TestHelper.tcp_send("TIERS.UPDATE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"
    assert response["tier"]["name"] == "New Name"
  end

  test "delete tier" do
    tier = tier_fixture()
    payload = %{"id" => tier.id}

    response = TestHelper.tcp_send("TIERS.DELETE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"

    # Ensure it's gone
    get_resp = TestHelper.tcp_send("TIERS.GET|" <> Jason.encode!(%{"id" => tier.id}))
    assert get_resp["status"] == "error"
  end
end
