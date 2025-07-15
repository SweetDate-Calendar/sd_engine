defmodule SDTCP.Handlers.AccountsTest do
  use SDTCP.DataCase, async: false
  import SD.AccountsFixtures
  import SDTCP.TestHelper

  test "list all accounts" do
    account_fixture(%{name: "One"})
    account_fixture(%{name: "Two"})

    response = sd_send("ACCOUNTS.LIST|" <> Jason.encode!(authorize(%{})))

    assert response["status"] == "ok"
    assert length(response["accounts"]) >= 2
  end

  test "ACCOUNDS.CREATE creates a new account with just a title" do
    payload = %{"name" => "RubyConf"} |> authorize()
    raw = "ACCOUNTS.CREATE|#{Jason.encode!(payload)}"
    response = sd_send(raw)

    assert %{"status" => "ok", "id" => id} = response
    assert is_binary(id)
  end

  test "fetch account by id" do
    account = account_fixture(%{name: "Fetch Me"})

    payload = %{"id" => account.id} |> authorize()
    get_resp = sd_send("ACCOUNTS.GET|" <> Jason.encode!(payload))

    assert get_resp["status"] == "ok"
    assert get_resp["account"]["name"] == "Fetch Me"
  end

  test "fetch account with invalid id returns error" do
    payload =
      %{"id" => "00000000-0000-0000-0000-000000000000"}
      |> authorize()

    response = sd_send("ACCOUNTS.GET|" <> Jason.encode!(payload))

    assert response["status"] == "error"
    assert response["message"] == "not found"
  end

  test "update account name" do
    account = account_fixture(%{name: "Old Name"})

    payload =
      %{
        "id" => account.id,
        "name" => "New Name",
        "sweet_date_account_id" => "demo_sweet_date_account_id",
        "access_key" => "demo_access_key"
      }
      |> authorize()

    response = sd_send("ACCOUNTS.UPDATE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"
    assert response["account"]["name"] == "New Name"
  end

  test "delete account" do
    account = account_fixture()
    payload = %{"id" => account.id} |> authorize()

    response = sd_send("ACCOUNTS.DELETE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"

    # Ensure it's gone
    get_resp = sd_send("ACCOUNTS.GET|" <> Jason.encode!(%{"id" => account.id}))
    assert get_resp["status"] == "error"
  end

  test "list calendars" do
    account = account_fixture()
    tier_a = SD.TiersFixtures.tier_fixture(%{account_id: account.id})
    calendar_a = SD.CalendarsFixtures.calendar_fixture(%{tier_id: tier_a.id})
    tier_b = SD.TiersFixtures.tier_fixture(%{account_id: account.id})
    calendar_b = SD.CalendarsFixtures.calendar_fixture(%{tier_id: tier_b.id})

    tier_c = SD.TiersFixtures.tier_fixture()
    _calendar_c = SD.CalendarsFixtures.calendar_fixture(%{tier_id: tier_c.id})

    payload = %{"id" => account.id} |> authorize()

    response = sd_send("ACCOUNTS.LIST_CALENDARS|" <> Jason.encode!(payload))
    assert response["status"] == "ok"

    expected = [
      %{
        "id" => calendar_a.id,
        "name" => calendar_a.name,
        "tier_id" => calendar_a.tier_id,
        "color_theme" => calendar_a.color_theme,
        "visibility" => to_string(calendar_a.visibility)
      },
      %{
        "id" => calendar_b.id,
        "name" => calendar_b.name,
        "tier_id" => calendar_b.tier_id,
        "color_theme" => calendar_b.color_theme,
        "visibility" => to_string(calendar_b.visibility)
      }
    ]

    # Allow either order
    assert Enum.sort_by(response["calendars"], & &1["id"]) ==
             Enum.sort_by(expected, & &1["id"])

    # assert SD.Accounts.list_calendars(account) == [calendar_a, calendar_b]
  end
end
