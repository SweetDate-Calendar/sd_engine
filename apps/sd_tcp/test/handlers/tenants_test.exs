defmodule SDTCP.Handlers.TenantsTest do
  use SDTCP.DataCase, async: false
  import SD.TenantsFixtures
  import SDTCP.TestHelper

  test "list all tenants" do
    tenant_fixture(%{name: "One"})
    tenant_fixture(%{name: "Two"})

    response = sd_send("TIERS.LIST|" <> Jason.encode!(authorize(%{})))
    assert response["status"] == "ok"
    assert length(response["tenants"]) >= 2
  end

  test "TIERS.CREATE creates a new tenant with just a title" do
    account = SD.AccountsFixtures.account_fixture()

    payload =
      %{"name" => "RubyConf", account_id: account.id}
      |> authorize()

    raw = "TIERS.CREATE|#{Jason.encode!(payload)}"
    response = sd_send(raw)

    assert %{"status" => "ok", "id" => id} = response
    assert is_binary(id)
  end

  test "fetch tenant by id" do
    tenant = tenant_fixture(%{name: "Fetch Me"})

    payload =
      %{"id" => tenant.id}
      |> authorize()

    get_resp = sd_send("TIERS.GET|" <> Jason.encode!(payload))

    assert get_resp["status"] == "ok"
    assert get_resp["tenant"]["name"] == "Fetch Me"
  end

  test "fetch tenant with invalid id returns error" do
    payload =
      %{"id" => "00000000-0000-0000-0000-000000000000"}
      |> authorize()

    response = sd_send("TIERS.GET|" <> Jason.encode!(payload))

    assert response["status"] == "error"
    assert response["message"] == "not found"
  end

  test "update tenant name" do
    tenant = tenant_fixture(%{name: "Old Name"})

    payload =
      %{
        "id" => tenant.id,
        "name" => "New Name"
      }
      |> authorize()

    response = sd_send("TIERS.UPDATE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"
    assert response["tenant"]["name"] == "New Name"
  end

  test "delete tenant" do
    tenant = tenant_fixture()

    payload =
      %{"id" => tenant.id}
      |> authorize()

    response = sd_send("TIERS.DELETE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"

    # Ensure it's gone
    get_resp = sd_send("TIERS.GET|" <> Jason.encode!(%{"id" => tenant.id}))
    assert get_resp["status"] == "error"
  end
end
