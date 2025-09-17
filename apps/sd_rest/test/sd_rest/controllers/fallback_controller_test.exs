defmodule SDRest.FallbackControllerTest do
  use SDRest.ConnCase, async: true
  alias SDRest.FallbackController
  import Phoenix.ConnTest

  describe "call/2" do
    test "returns 404 for :not_found", %{conn: conn} do
      conn = FallbackController.call(conn, {:error, :not_found})

      assert conn.status == 404

      assert json_response(conn, 404) == %{
               "status" => "error",
               "message" => "not found"
             }
    end

    test "returns 401 for :unauthorized", %{conn: conn} do
      conn = FallbackController.call(conn, {:error, :unauthorized})

      assert conn.status == 401

      assert json_response(conn, 401) == %{
               "status" => "error",
               "message" => "unauthorized"
             }
    end

    test "returns 403 for :forbidden", %{conn: conn} do
      conn = FallbackController.call(conn, {:error, :forbidden})

      assert conn.status == 403

      assert json_response(conn, 403) == %{
               "status" => "error",
               "message" => "forbidden"
             }
    end

    test "returns 422 for changeset errors", %{conn: conn} do
      cs =
        {%{}, %{name: :string}}
        |> Ecto.Changeset.cast(%{}, [:name])
        |> Ecto.Changeset.validate_required([:name])

      conn = FallbackController.call(conn, {:error, cs})

      assert conn.status == 422

      body = json_response(conn, 422)

      assert body["status"] == "error"
      assert body["message"] == "invalid input"
      assert body["error_code"] == "VALIDATION_ERROR"
      assert %{"name" => _} = body["fields"]
    end

    test "returns 400 for other errors", %{conn: conn} do
      conn = FallbackController.call(conn, {:error, :some_bad_reason})

      assert conn.status == 400

      assert json_response(conn, 400) == %{
               "status" => "error",
               "message" => "some_bad_reason"
             }
    end
  end
end
