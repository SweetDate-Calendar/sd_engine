defmodule SDTCP.Handlers.AuthTest do
  use SDTCP.DataCase, async: false
  import SDTCP.TestHelper
  import SD.TiersFixtures

  test "authorized?/1 fails if account not found" do
    tier = tier_fixture()

    payload =
      %{"id" => tier.id, "name" => "New Name"}
      |> authorize()

    assert sd_send("TIERS.UPDATE|" <> Jason.encode!(payload)) ==
             %{"message" => "unauthorized", "status" => "error"}
  end
end
