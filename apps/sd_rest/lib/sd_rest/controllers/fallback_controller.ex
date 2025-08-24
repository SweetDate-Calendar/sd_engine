# apps/sd_rest/lib/sd_rest/controllers/fallback_controller.ex
defmodule SDRest.FallbackController do
  use SDRest, :controller
  alias SDRest.ChangesetErrors

  # Not found (your contexts can return {:error, :not_found})
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{"status" => "error", "message" => "not found"})
  end

  # Unauthorized / Forbidden (optional patterns you’ll likely use elsewhere)
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{"status" => "error", "message" => "unauthorized"})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json(%{"status" => "error", "message" => "forbidden"})
  end

  # Validation errors
  def call(conn, {:error, %Ecto.Changeset{} = cs}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      "status" => "error",
      "message" => "invalid input",
      "error_code" => "VALIDATION_ERROR",
      "fields" => ChangesetErrors.to_map(cs)
    })
  end

  # Conservative default
  def call(conn, {:error, reason}) do
    conn
    |> put_status(:bad_request)
    |> json(%{"status" => "error", "message" => to_string(reason)})
  end
end
