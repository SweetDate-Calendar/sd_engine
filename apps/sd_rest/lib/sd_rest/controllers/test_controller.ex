defmodule SDRest.TestController do
  use SDRest, :controller

  @doc """
  POST /api/v1/test/prune
  Body: { "seed": "abc123" }

  Response:
    200: {"status":"ok","deleted":N}
    400: {"status":"error","message":"seed required"}
  """
  def prune(conn, %{"seed" => seed}) do
    case SD.Tenants.prune_test_data(seed) do
      {:ok, count} ->
        json(conn, %{"status" => "ok", "deleted" => count})

      {:error, :seed_required} ->
        conn
        |> put_status(:bad_request)
        |> json(%{"status" => "error", "message" => "seed required"})
    end
  end
end
