defmodule SDRest.TestController do
  use SDRest, :controller

  # Small helper: broadcast "pruned" after we delete test data
  defp broadcast_pruned() do
    Phoenix.PubSub.broadcast(SD.PubSub, "tenants", %Phoenix.Socket.Broadcast{
      topic: "tenants",
      event: "pruned"
    })
  end

  @doc """
  POST /api/v1/test/prune
  Body: { "seed": "abc123" }

  200: {"status":"ok","deleted":N}
  400: {"status":"error","message":"seed required"}
  """
  def prune(conn, %{"seed" => seed}) do
    case SD.Tenants.prune_test_data(seed) do
      {:ok, count} ->
        broadcast_pruned()

        conn
        |> put_status(:ok)
        |> json(%{"status" => "ok", "deleted" => count})

      {:error, :seed_required} ->
        conn
        |> put_status(:bad_request)
        |> json(%{"status" => "error", "message" => "seed required"})
    end
  end
end
