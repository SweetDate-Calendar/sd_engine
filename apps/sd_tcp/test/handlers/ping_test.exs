defmodule SDTCP.Handlers.PingTest do
  use SDTCP.DataCase, async: false
  import SDTCP.TestHelper
  import SD.AccountsFixtures

  describe "authorized" do
    setup do
      account = authorized_account_fixture()

      %{account: account}
    end

    test "responds with pong on PING" do
      assert %{"status" => "ok", "message" => "pong"} =
               sd_send("PING|" <> Jason.encode!(authorize(%{})))
    end
  end

  test "responds with unauthorized" do
    assert %{"message" => "unauthorized", "status" => "error"} =
             sd_send("PING|" <> Jason.encode!(%{}))
  end
end
