defmodule ClpTcp.Handlers.AccountsTest do
  use ClpTcp.DataCase, async: false
  import CLP.AccountsFixtures
  alias ClpTcp.TestHelper

  test "list all accounts" do
    account_fixture(%{name: "One"})
    account_fixture(%{name: "Two"})

    response = TestHelper.tcp_send("ACCOUNTS.LIST|{}")
    assert response["status"] == "ok"
    assert length(response["accounts"]) >= 2
  end

  test "ACCOUNDS.CREATE creates a new account with just a title" do
    payload = %{"name" => "RubyConf"}
    raw = "ACCOUNTS.CREATE|#{Jason.encode!(payload)}"
    response = TestHelper.tcp_send(raw)

    assert %{"status" => "ok", "id" => id} = response
    assert is_binary(id)
  end

  test "fetch account by id" do
    account = account_fixture(%{name: "Fetch Me"})

    payload = %{"id" => account.id}
    get_resp = TestHelper.tcp_send("ACCOUNTS.GET|" <> Jason.encode!(payload))

    assert get_resp["status"] == "ok"
    assert get_resp["account"]["name"] == "Fetch Me"
  end

  test "fetch account with invalid id returns error" do
    payload = %{"id" => "00000000-0000-0000-0000-000000000000"}

    response = TestHelper.tcp_send("ACCOUNTS.GET|" <> Jason.encode!(payload))

    assert response["status"] == "error"
    assert response["message"] == "not found"
  end

  test "update account name" do
    account = account_fixture(%{name: "Old Name"})

    payload = %{
      "id" => account.id,
      "name" => "New Name"
    }

    response = TestHelper.tcp_send("ACCOUNTS.UPDATE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"
    assert response["account"]["name"] == "New Name"
  end

  test "delete account" do
    account = account_fixture()
    payload = %{"id" => account.id}

    response = TestHelper.tcp_send("ACCOUNTS.DELETE|" <> Jason.encode!(payload))
    assert response["status"] == "ok"

    # Ensure it's gone
    get_resp = TestHelper.tcp_send("ACCOUNTS.GET|" <> Jason.encode!(%{"id" => account.id}))
    assert get_resp["status"] == "error"
  end
end
