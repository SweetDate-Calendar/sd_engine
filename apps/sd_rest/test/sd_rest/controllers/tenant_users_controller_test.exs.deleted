defmodule SDRest.TenantUsersControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  import Phoenix.ConnTest
  import SD.TenantsFixtures
  import SD.AccountsFixtures

  @tenants_base "/api/v1/tenants"

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  describe "index (GET /tenants/:tenant_id/users)" do
    test "lists users for the given tenant with default pagination", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team A"})
      u1 = user_fixture(%{name: "Alpha", email: "alpha@example.com"})
      u2 = user_fixture(%{name: "Beta", email: "beta@example.com"})
      SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: u1.id, role: :owner})
      SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: u2.id, role: :guest})

      path = "#{@tenants_base}/#{tenant.id}/users"
      conn = signed_get(conn, path)

      %{"status" => "ok", "users" => users} = json_response(conn, 200)

      assert length(users) == 2

      Enum.each(users, fn u ->
        assert is_binary(u["id"])
        assert is_binary(u["name"])
        assert is_binary(u["email"])
        assert is_binary(u["role"])
        assert is_binary(u["inserted_at"])
        assert is_binary(u["updated_at"])
      end)

      # verify the right users (order not guaranteed)
      emails = users |> Enum.map(& &1["email"]) |> Enum.sort()
      assert emails == ["alpha@example.com", "beta@example.com"]

      roles_by_email = Map.new(users, &{&1["email"], &1["role"]})
      assert roles_by_email["alpha@example.com"] == "owner"
      assert roles_by_email["beta@example.com"] == "guest"
    end

    test "respects limit & offset", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team B"})
      u1 = user_fixture(%{name: "A", email: "a@example.com"})
      u2 = user_fixture(%{name: "B", email: "b@example.com"})
      u3 = user_fixture(%{name: "C", email: "c@example.com"})
      _ = SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: u1.id, role: :guest})
      _ = SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: u2.id, role: :guest})
      _ = SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: u3.id, role: :guest})

      conn = signed_get(conn, "#{@tenants_base}/#{tenant.id}/users?limit=2&offset=1")

      %{"status" => "ok", "users" => users} = json_response(conn, 200)
      assert length(users) == 2
    end

    test "404 when tenant id invalid or not found", %{conn: conn} do
      conn1 = signed_get(conn, "#{@tenants_base}/not-a-uuid/users")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn1, 404)

      conn2 = signed_get(conn, "#{@tenants_base}/00000000-0000-0000-0000-000000000000/users")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn2, 404)
    end
  end

  describe "create (POST /tenants/:tenant_id/users)" do
    test "creates tenant_user and returns the user view", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team C"})
      user = user_fixture(%{name: "Gamma", email: "gamma@example.com"})

      path = "#{@tenants_base}/#{tenant.id}/users"
      conn = signed_post(conn, path, %{"user_id" => user.id, "role" => "admin"})

      %{
        "status" => "ok",
        "user" => u
      } = json_response(conn, 201)

      assert u["id"] == user.id
      assert u["name"] == "Gamma"
      assert u["email"] == "gamma@example.com"
      assert u["role"] == "admin"
      assert is_binary(u["inserted_at"])
      assert is_binary(u["updated_at"])
    end

    test "422 when payload invalid", %{conn: conn} do
      tenant = tenant_fixture()

      # missing user_id
      conn = signed_post(conn, "#{@tenants_base}/#{tenant.id}/users", %{"role" => "guest"})

      # Expect your FallbackController validation shape
      %{
        "status" => "error",
        "message" => _msg,
        "error_code" => _code,
        "fields" => _fields
      } = json_response(conn, 422)
    end

    test "404 when tenant invalid/not found", %{conn: conn} do
      # invalid tenant id format
      conn1 =
        signed_post(conn, "#{@tenants_base}/not-a-uuid/users", %{
          "user_id" => Ecto.UUID.generate()
        })

      assert %{"status" => "error", "message" => "not found"} = json_response(conn1, 404)

      # non-existent tenant uuid
      conn2 =
        signed_post(
          conn,
          "#{@tenants_base}/00000000-0000-0000-0000-000000000000/users",
          %{"user_id" => Ecto.UUID.generate()}
        )

      assert %{"status" => "error", "message" => "not found"} = json_response(conn2, 404)
    end
  end

  describe "show (GET /tenants/:tenant_id/users/:id)" do
    test "returns the user", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team D"})
      user = user_fixture(%{name: "Delta", email: "delta@example.com"})
      _ = SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: user.id, role: :guest})

      conn = signed_get(conn, "#{@tenants_base}/#{tenant.id}/users/#{user.id}")

      %{"status" => "ok", "user" => u} = json_response(conn, 200)

      assert u["id"] == user.id
      assert u["name"] == "Delta"
      assert u["email"] == "delta@example.com"
      assert is_binary(u["role"])
      assert is_binary(u["inserted_at"])
      assert is_binary(u["updated_at"])
    end

    test "404 when user is not a member", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team E"})
      user = user_fixture(%{name: "Echo", email: "echo@example.com"})

      conn = signed_get(conn, "#{@tenants_base}/#{tenant.id}/users/#{user.id}")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn, 404)
    end
  end

  describe "update (PUT /tenants/:tenant_id/users/:id)" do
    test "updates role and returns user view", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team F"})
      user = user_fixture(%{name: "Foxtrot", email: "foxtrot@example.com"})

      {:ok, tenant_user} =
        SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: user.id, role: :guest})

      conn =
        signed_put(conn, "#{@tenants_base}/#{tenant.id}/users/#{tenant_user.user_id}", %{
          "role" => "owner"
        })

      %{
        "status" => "ok",
        "user" => u
      } = json_response(conn, 200)

      assert u["id"] == user.id
      assert u["email"] == "foxtrot@example.com"
      assert u["role"] == "owner"
    end

    test "404 when tenant or user id invalid", %{conn: conn} do
      conn1 =
        signed_put(conn, "#{@tenants_base}/not-a-uuid/users/#{Ecto.UUID.generate()}", %{
          "role" => "admin"
        })

      assert %{"status" => "error", "message" => "not found"} = json_response(conn1, 404)

      tenant = tenant_fixture()

      conn2 =
        signed_put(conn, "#{@tenants_base}/#{tenant.id}/users/not-a-uuid", %{"role" => "admin"})

      assert %{"status" => "error", "message" => "not found"} = json_response(conn2, 404)
    end

    test "422 when invalid payload", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team G"})
      user = user_fixture(%{name: "Golf", email: "golf@example.com"})

      {:ok, _} =
        SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: user.id, role: :guest})

      conn =
        signed_put(conn, "#{@tenants_base}/#{tenant.id}/users/#{user.id}", %{
          "role" => "pop-singer"
        })

      # Expect your FallbackController validation shape
      %{
        "status" => "error",
        "message" => _msg,
        "error_code" => _code,
        "fields" => _fields
      } = json_response(conn, 422)
    end
  end

  describe "delete (DELETE /tenants/:tenant_id/users/:id)" do
    test "deletes tenant_user and returns status ok", %{conn: conn} do
      tenant = tenant_fixture(%{name: "Team H"})
      user = user_fixture(%{name: "Hotel", email: "hotel@example.com"})

      {:ok, _tu} =
        SD.Tenants.create_tenant_user(%{tenant_id: tenant.id, user_id: user.id, role: :owner})

      conn = signed_delete(conn, "#{@tenants_base}/#{tenant.id}/users/#{user.id}")

      %{"status" => "ok"} = json_response(conn, 200)

      # Ensure user is no longer listed under the tenant
      conn2 = signed_get(build_conn(), "#{@tenants_base}/#{tenant.id}/users")
      %{"status" => "ok", "users" => users2} = json_response(conn2, 200)
      refute Enum.any?(users2, &(&1["id"] == user.id))
    end

    test "404 when tenant or user id invalid/not found", %{conn: conn} do
      conn1 = signed_delete(conn, "#{@tenants_base}/not-a-uuid/users/#{Ecto.UUID.generate()}")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn1, 404)

      tenant = tenant_fixture()
      conn2 = signed_delete(conn, "#{@tenants_base}/#{tenant.id}/users/#{Ecto.UUID.generate()}")
      assert %{"status" => "error", "message" => "not found"} = json_response(conn2, 404)
    end
  end
end
