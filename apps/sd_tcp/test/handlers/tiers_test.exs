defmodule SDTCP.Handlers.TiersTest do
  use SDTCP.DataCase, async: false
  import SD.TiersFixtures
  import SDTCP.TestHelper

  test "list all tiers" do
    tier_fixture(%{name: "One"})
    tier_fixture(%{name: "Two"})

    response = sd_send("TIERS.LIST|" <> Jason.encode!(authorize(%{})))
    assert response["status"] == "ok"
    assert length(response["tiers"]) >= 2
  end

  test "TIERS.CREATE creates a new tier with just a title" do
    account = SD.AccountsFixtures.account_fixture()

    payload =
      %{"name" => "RubyConf", account_id: account.id}
      |> authorize()

    raw = "TIERS.CREATE|#{Jason.encode!(payload)}"
    response = sd_send(raw)

    assert %{"status" => "ok", "id" => id} = response
    assert is_binary(id)
  end

  test "fetch tier by id" do
    tier = tier_fixture(%{name: "Fetch Me"})

    payload =
      %{"id" => tier.id}
      |> authorize()

    get_resp = sd_send("TIERS.GET|" <> Jason.encode!(payload))

    assert get_resp["status"] == "ok"
    assert get_resp["tier"]["name"] == "Fetch Me"
  end

  test "fetch tier with invalid id returns error" do
    payload =
      %{"id" => "00000000-0000-0000-0000-000000000000"}
      |> authorize()

    response = sd_send("TIERS.GET|" <> Jason.encode!(payload))

    assert response["status"] == "error"
    assert response["message"] == "not found"
  end

  test "update tier name" do
    tier = tier_fixture(%{name: "Old Name"})

    payload =
      %{
        "id" => tier.id,
        "name" => "New Name"
      }
      |> authorize()

    response = sd_send("TIERS.UPDATE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"
    assert response["tier"]["name"] == "New Name"
  end

  test "delete tier" do
    tier = tier_fixture()

    payload =
      %{"id" => tier.id}
      |> authorize()

    response = sd_send("TIERS.DELETE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"

    # Ensure it's gone
    get_resp = sd_send("TIERS.GET|" <> Jason.encode!(%{"id" => tier.id}))
    assert get_resp["status"] == "error"
  end
end
