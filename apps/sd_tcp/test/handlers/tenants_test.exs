defmodule SDTCP.Handlers.TenantsTest do
  use SDTCP.DataCase, async: false
  import SD.TenantsFixtures
  import SDTCP.TestHelper
  import SD.AccountsFixtures

  describe "tenants" do
    setup do
      account = authorized_account_fixture()

      %{account: account}
    end

    test "list all tenants", %{account: account} do
      tenant_fixture(%{account_id: account.id, name: "One"})
      tenant_fixture(%{account_id: account.id, name: "Two"})

      response =
        sd_send("TENANTS.LIST|" <> Jason.encode!(authorize(%{sweet_date_account_id: account.id})))

      assert response["status"] == "ok"
      assert length(response["tenants"]) >= 2
    end

    test "TENANTS.CREATE creates a new tenant with just a title", %{account: account} do
      payload =
        %{"name" => "RubyConf", "account_id" => account.id}
        |> authorize()

      raw = "TENANTS.CREATE|#{Jason.encode!(payload)}"
      response = sd_send(raw)

      assert %{
               "status" => "ok",
               "tenant" => %{
                 "id" => id,
                 "name" => "RubyConf",
                 "account_id" => account_id
               }
             } = response

      assert is_binary(id)
      assert account_id == account.id
    end

    test "fetch tenant by id" do
      tenant = tenant_fixture(%{name: "Fetch Me"})

      payload =
        %{"id" => tenant.id}
        |> authorize()

      response = sd_send("TENANTS.GET|" <> Jason.encode!(payload))

      assert response["status"] == "ok"
      assert response["tenant"]["name"] == "Fetch Me"
    end

    test "fetch tenant with invalid id returns error" do
      payload =
        %{"id" => "00000000-0000-0000-0000-000000000000"}
        |> authorize()

      response = sd_send("TENANTS.GET|" <> Jason.encode!(payload))

      assert response["status"] == "error"
      assert response["message"] == "not found"
    end

    test "update tenant name", %{account: account} do
      tenant = tenant_fixture(%{account_id: account.id, name: "Old Name"})

      payload =
        %{
          "id" => tenant.id,
          "name" => "New Name"
        }
        |> authorize()

      response = sd_send("TENANTS.UPDATE|" <> Jason.encode!(payload))
      assert response["status"] == "ok"
      assert response["tenant"]["name"] == "New Name"
    end

    test "delete tenant" do
      tenant = tenant_fixture()

      payload =
        %{"id" => tenant.id}
        |> authorize()

      response = sd_send("TENANTS.DELETE|" <> Jason.encode!(payload))
      assert response["status"] == "ok"

      # Ensure it's gone
      get_resp = sd_send("TENANTS.GET|" <> Jason.encode!(%{"id" => tenant.id}))
      assert get_resp["status"] == "error"
    end
  end
end
