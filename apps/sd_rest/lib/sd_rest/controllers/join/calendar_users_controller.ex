defmodule SDRest.Join.CalendarUsersController do
  use SDRest, :controller

  import SDRest.ControllerHelpers
  alias SD.Calendars

  def create(conn, params) do
    with {:ok, calendar_user} <- Calendars.create_calendar_user(params) do
      calendar_user =
        calendar_user
        |> SD.Repo.preload(:user)

      json(conn |> put_status(:created), %{
        "status" => "ok",
        "user" =>
          calendar_user.user
          |> Map.from_struct()
          |> Map.take([:id, :name, :email])
          |> Map.merge(%{
            "role" => calendar_user.role,
            "inserted_at" => calendar_user.inserted_at,
            "updated_at" => calendar_user.updated_at
          })
      })
    else
      {:error, changeset} ->
        json(conn |> put_status(:unprocessable_entity), %{
          "status" => "error",
          "message" => translate_changeset_errors(changeset)
        })
    end
  end

  def update(conn, params) do
    case Calendars.get_calendar_user(params) do
      {:ok, calendar_user} ->
        case Calendars.update_calendar_user(calendar_user, params) do
          {:ok, calendar_user} ->
            json(conn, %{
              "status" => "ok",
              "user" =>
                calendar_user.user
                |> Map.from_struct()
                |> Map.take([:id, :name, :email])
                |> Map.merge(%{
                  "role" => calendar_user.role,
                  "inserted_at" => calendar_user.inserted_at,
                  "updated_at" => calendar_user.updated_at
                })
            })

          {:error, message} ->
            json(conn, %{
              "status" => "error",
              "message" => message
            })
        end

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :invalid_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid id"})
    end
  end

  def delete(conn, %{"calendar_id" => calendar_id, "id" => user_id}) do
    case Calendars.delete_calendar_user(calendar_id, user_id) do
      {:ok, _calendar_user} ->
        json(conn, %{"status" => "ok"})

      {:error, :not_found} ->
        json(conn |> put_status(:not_found), %{
          "status" => "error",
          "message" => "not found"
        })
    end
  end
end
