defmodule SDRest.Join.EventUsersController do
  use SDRest, :controller
  import SDRest.ControllerHelpers

  alias SD.Calendars

  def create(conn, params) do
    with {:ok, join} <- Calendars.create_event_user(params) do
      json(conn |> put_status(:created), %{
        "status" => "ok",
        "calendar_event_user" => join
      })
    else
      {:error, changeset} ->
        json(conn |> put_status(:unprocessable_entity), %{
          "status" => "error",
          "message" => "validation failed",
          "details" => translate_changeset_errors(changeset)
        })
    end
  end

  def update(conn, params) do
    params = Map.put(params, "user_id", params["id"])

    case Calendars.get_calendar_user(params) do
      {:ok, calendar_user} ->
        json(conn, %{
          "status" => "ok",
          "calendar_id" => calendar_user.calendar_id,
          "user" => calendar_user.user
        })

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :invalid_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid id"})
    end
  end

  def delete(conn, %{"id" => id}) do
    case Calendars.delete_event_user(id) do
      {:ok, join} ->
        json(conn, %{"status" => "ok", "calendar_event_user" => join})

      {:error, :not_found} ->
        json(conn |> put_status(:not_found), %{
          "status" => "error",
          "message" => "not found"
        })
    end
  end
end
