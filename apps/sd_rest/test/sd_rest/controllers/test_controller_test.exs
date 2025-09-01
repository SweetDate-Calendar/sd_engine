defmodule SDRest.TestControllerTest do
  use SDRest.ConnCase, async: true
  use SDRest.SignedRequestHelpers

  import Phoenix.ConnTest
  import SD.TenantsFixtures

  @base "/api/v1/test/prune"

  test "POST /api/v1/test/prune deletes CI-tagged tenants and returns count", %{conn: conn} do
    seed = "abc123"

    # create a couple of tagged tenants and one untagged
    tenant_fixture(%{name: "Foo [CI:#{seed}]"})
    tenant_fixture(%{name: "Bar [CI:#{seed}]"})
    # should remain
    tenant_fixture(%{name: "Baz"})

    conn = signed_post(conn, @base, %{"seed" => seed})

    %{"status" => "ok", "deleted" => deleted} = json_response(conn, 200)
    assert is_integer(deleted) and deleted >= 2
  end
end
