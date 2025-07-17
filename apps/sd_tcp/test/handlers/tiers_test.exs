defmodule SDTCP.Handlers.TiersTest do
  use SDTCP.DataCase, async: false
  import SD.TiersFixtures
  import SDTCP.TestHelper

  describe "tiers" do
    setup do
      {:ok, account} = SD.AccountsFixtures.create_authorized_account()

      Application.put_env(:sd_engine, :tcp,
        sweet_date_account_id: account.id,
        sweet_access_api_key: account.api_secret
      )

      %{account: account}
    end

    test "list all tiers", %{account: account} do
      tier_fixture(%{account_id: account.id, name: "One"})
      tier_fixture(%{account_id: account.id, name: "Two"})

      response = sd_send("TIERS.LIST|" <> Jason.encode!(authorize(%{})))
      assert response["status"] == "ok"
      assert length(response["tiers"]) >= 2
    end

    test "TIERS.CREATE creates a new tier with just a title" do
      payload =
        %{"name" => "RubyConf"}
        |> authorize()

      raw = "TIERS.CREATE|#{Jason.encode!(payload)}"
      response = sd_send(raw)

      assert %{"message" => tier_id, "status" => "ok"} = response
      assert is_binary(tier_id)
    end

    test "TIERS.GET get a tier by id" do
      tier = tier_fixture(%{name: "Fetch Me"})

      payload = %{"id" => tier.id} |> authorize()

      assert sd_send("TIERS.GET|" <> Jason.encode!(payload)) === %{
               "message" => %{"name" => "Fetch Me"},
               "status" => "ok"
             }
    end

    test "get tier with invalid id returns error" do
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
        %{"id" => tier.id, "name" => "New Name"}
        |> authorize()

      assert sd_send("TIERS.UPDATE|" <> Jason.encode!(payload)) == %{
               "status" => "ok",
               "message" => "tier updated"
             }
    end

    test "delete tier" do
      tier = tier_fixture()

      payload = %{"id" => tier.id} |> authorize()

      assert sd_send("TIERS.DELETE|" <> Jason.encode!(payload)) == %{
               "message" => "tier deleted",
               "status" => "ok"
             }

      refute SD.Tiers.get_tier(tier.id)
    end
  end
end
