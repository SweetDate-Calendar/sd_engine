defmodule SDTCP.Handlers.PingTest do
  use SDTCP.DataCase, async: false
  import SDTCP.TestHelper

  describe "ping authorized" do
    setup do
      {:ok, account} = SD.AccountsFixtures.create_authorized_account()

      Application.put_env(:sd_engine, :tcp,
        sweet_date_account_id: account.id,
        sweet_access_api_key: account.api_secret
      )

      :ok
    end

    test "responds with pong on PING" do
      assert %{"status" => "ok", "message" => "pong"} =
               sd_send("PING|" <> Jason.encode!(authorize(%{})))
    end
  end
end
