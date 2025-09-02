defmodule SDRest.Join.CalendarUsersController do
  use SDRest, :controller

  import SDRest.ControllerHelpers

  alias SD.Calendars

  def create(conn, params) do
    with {:ok, join} <- Calendars.create_calendar_user(params) do
      json(conn |> put_status(:created), %{
        "status" => "ok",
        "calendar_user" => join
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

  def update(conn, %{"id" => id} = params) do
    case Calendars.update_calendar_user(id, params) do
      {:ok, join} ->
        json(conn, %{"status" => "ok", "calendar_user" => join})

      {:error, :not_found} ->
        json(conn |> put_status(:not_found), %{
          "status" => "error",
          "message" => "not found"
        })

      {:error, changeset} ->
        json(conn |> put_status(:unprocessable_entity), %{
          "status" => "error",
          "message" => "validation failed",
          "details" => translate_changeset_errors(changeset)
        })
    end
  end

  def delete(conn, %{"id" => id}) do
    case Calendars.delete_calendar_user(id) do
      {:ok, join} ->
        json(conn, %{"status" => "ok", "calendar_user" => join})

      {:error, :not_found} ->
        json(conn |> put_status(:not_found), %{
          "status" => "error",
          "message" => "not found"
        })
    end
  end
end
