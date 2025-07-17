defmodule SDTCP.Handlers.CalendarsTest do
  use SDTCP.DataCase, async: false
  import SD.CalendarsFixtures
  import SDTCP.TestHelper

  describe "calendars" do
    setup do
      {:ok, account} = SD.AccountsFixtures.create_authorized_account()
      tier = SD.TiersFixtures.tier_fixture(%{account_id: account.id})

      Application.put_env(:sd_engine, :tcp,
        sweet_date_account_id: account.id,
        sweet_access_api_key: account.api_secret
      )

      %{account: account, tier: tier}
    end

    test "list all calendars", %{tier: tier} do
      # account_id = account.id
      calendar_fixture(%{name: "One", tier_id: tier.id})
      calendar_fixture(%{name: "Two", tier_id: tier.id})

      response = sd_send("CALENDARS.LIST|" <> Jason.encode!(authorize(%{"tier_id" => tier.id})))

      assert response["status"] == "ok"
      assert length(response["calendars"]) >= 2
    end

    test "CALENDARS.CREATE creates a new calendar with just a title", %{tier: tier} do
      payload =
        %{
          "tier_id" => tier.id,
          "name" => "RubyConf",
          "color_theme" => "default",
          "visibility" => "tiered"
        }
        |> authorize()

      raw = "CALENDARS.CREATE|" <> Jason.encode!(payload)
      response = sd_send(raw)

      assert %{"status" => "ok", "id" => id} = response
      assert is_binary(id)
    end

    test "CALENDARS.GET returns calendar by id", %{tier: tier} do
      calendar = calendar_fixture(%{tier_id: tier.id, name: "Fetch Me"})

      payload = %{"id" => calendar.id} |> authorize()

      raw = "CALENDARS.GET|#{Jason.encode!(payload)}"
      response = sd_send(raw)

      assert response == %{
               "calendar" => %{
                 "color_theme" => calendar.color_theme,
                 "id" => calendar.id,
                 "name" => calendar.name,
                 "visibility" => "public"
               },
               "status" => "ok"
             }
    end

    test "fetch calendar with invalid id returns error" do
      payload = %{"id" => "00000000-0000-0000-0000-000000000000"} |> authorize()

      response = sd_send("CALENDARS.GET|" <> Jason.encode!(payload))

      assert response["status"] == "error"
      assert response["message"] == "not found"
    end

    test "CALENDARS.UPDATE update calendar", %{tier: tier} do
      calendar = calendar_fixture(%{tier_id: tier.id, name: "Old Name"})

      payload =
        %{
          "id" => calendar.id,
          "name" => "New Name"
        }
        |> authorize()

      response = sd_send("CALENDARS.UPDATE|" <> Jason.encode!(payload))
      IO.inspect(response)
      assert response["status"] == "ok"
      assert response["message"] == "calendar updated"
    end

    test "CALENDARS.DELETE delete calendar", %{tier: tier} do
      calendar = calendar_fixture(%{tier_id: tier.id})
      payload = %{"id" => calendar.id} |> authorize()

      response = sd_send("CALENDARS.DELETE|" <> Jason.encode!(payload))
      assert response == %{"message" => "calendar deleted", "status" => "ok"}
    end
  end
end
