defmodule SDRest.TestControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers
  alias SD.Accounts
  alias SD.Tenants

  import Phoenix.ConnTest
  import SD.TenantsFixtures
  import SD.AccountsFixtures

  @seed_endpoint "/api/v1/test/seed"
  @prune_endpoint "/api/v1/test/prune"
  @seed System.get_env("SD_APP_ID") <> "-test"
  P

  describe "POST /api/v1/test/prune" do
    test "POST /api/v1/test/prune deletes CI-tagged users and returns count", %{conn: conn} do
      seed = "abc123"

      # Create two CI-tagged users and one regular user
      u1 = user_fixture(%{name: "Foo [CI:#{seed}]"})
      u2 = user_fixture(%{name: "Bar [CI:#{seed}]"})
      # Should remain
      u3 = user_fixture(%{name: "Baz"})

      # Make the call
      conn = signed_post(conn, @prune_endpoint, %{"seed" => seed, "model" => "user"})

      # Assert response shape
      %{"status" => "ok", "deleted" => _deleted} = json_response(conn, 200)

      # Confirm u1 and u2 are gone, u3 remains
      assert is_nil(Accounts.get_user(u1.id))
      assert is_nil(Accounts.get_user(u2.id))
      assert Accounts.get_user(u3.id).name == "Baz"
    end

    test "POST /api/v1/test/prune deletes CI-tagged tenants and returns count", %{conn: conn} do
      seed = "abc123"

      # Create two CI-tagged users and one regular user
      tenant1 = tenant_fixture(%{name: "Foo [CI:#{seed}]"})
      tenant2 = tenant_fixture(%{name: "Bar [CI:#{seed}]"})
      # Should remain
      tenant3 = tenant_fixture(%{name: "Baz"})

      # Make the call
      conn = signed_post(conn, @prune_endpoint, %{"seed" => seed, "model" => "tenant"})

      # Assert response shape
      %{"status" => "ok", "deleted" => _deleted} = json_response(conn, 200)

      # Confirm u1 and u2 are gone, u3 remains
      assert is_nil(Tenants.get_tenant(tenant1.id))
      assert is_nil(Tenants.get_tenant(tenant2.id))
      assert Tenants.get_tenant(tenant3.id).name == "Baz"
    end
  end

  describe "POST /api/v1/test/seed" do
    test "seeds users with CI-tagged names", %{conn: conn} do
      count = "8"

      conn =
        signed_post(conn, @seed_endpoint, %{
          "model" => "user",
          "seed" => @seed,
          "count" => count
        })

      %{
        "status" => "ok",
        "users" => count
      } = json_response(conn, 200)

      matches = SD.Accounts.list_users(q: @seed)

      assert length(matches) >= String.to_integer(count)
    end

    test "seeds tenants with CI-tagged names", %{conn: conn} do
      count = "8"

      conn =
        signed_post(conn, @seed_endpoint, %{
          "model" => "tenant",
          "seed" => @seed,
          "count" => count
        })

      %{
        "status" => "ok",
        "tenants" => count
      } = json_response(conn, 200)

      matches = SD.Tenants.list_tenants(q: @seed)

      assert length(matches) >= String.to_integer(count)
    end
  end
end
