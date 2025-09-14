defmodule SDRest.TestController do
  use SDRest, :controller

  # Small helper: broadcast "pruned" after we delete test data
  defp prune_tenants(seed) do
    Phoenix.PubSub.broadcast(SD.PubSub, "tenants", %Phoenix.Socket.Broadcast{
      topic: "tenants",
      event: "pruned"
    })

    SD.Tenants.prune_test_data(seed)
  end

  defp prune_users(seed) do
    Phoenix.PubSub.broadcast(SD.PubSub, "users", %Phoenix.Socket.Broadcast{
      topic: "users",
      event: "pruned"
    })

    SD.Accounts.prune_test_data(seed)
  end

  @doc """
  POST /api/v1/test/prune

  Body: { "seed": "abc123", "model": "users" }

  Response:
    200 OK: {"status": "ok", "deleted": N}
    400 Bad Request: {"status": "error", "message": "..."}
  """
  def prune(conn, %{"seed" => seed, "model" => model})
      when is_binary(seed) and is_binary(model) do
    {:ok, count} =
      case model do
        "user" ->
          prune_users(seed)

        "tenant" ->
          prune_tenants(seed)

        "calendar" ->
          {:ok, 0}

        _ ->
          conn
          |> put_status(:bad_request)
          |> json(%{"status" => "error", "message" => "unknown model: #{model}"})
          |> halt()
      end

    json(conn, %{"status" => "ok", "deleted" => "#{count}"})
  end

  def prune(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{"status" => "error", "message" => "seed and model required"})
  end

  def seed(conn, %{"seed" => seed, "model" => model, "count" => count}) do
    case model do
      "user" ->
        Enum.each(0..(String.to_integer(count) - 1), fn i ->
          name = "user.#{i}.#{seed}"
          email = "#{name}@example.com"
          SD.Accounts.create_user(%{name: name, email: email})
        end)

        json(conn, %{"status" => "ok", "users" => count})

      "tenant" ->
        Enum.each(0..(String.to_integer(count) - 1), fn i ->
          name = "tenant.#{i}.#{seed}"

          SD.Tenants.create_tenant(%{name: name})
        end)

        json(conn, %{"status" => "ok", "tenants" => count})

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{"status" => "error", "message" => "Unknown model: #{model}"})
    end

    # conn |> json(%{"status" => "error", "message" => "Unknown model: #{model}"})
  end

  def seed(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{"status" => "error", "message" => "seed, model and count required"})
  end
end
