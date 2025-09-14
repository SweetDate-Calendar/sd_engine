defmodule SDRest.Join.EventUsersController do
  use SDRest, :controller
  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100

  alias SD.Calendars

  def create(conn, params) do
    with {:ok, event_user} <- Calendars.create_event_user(params) do
      user =
        event_user.user
        |> Map.from_struct()
        |> Map.take([:id, :email, :name])
        |> Map.merge(%{
          "role" => event_user.role,
          "status" => event_user.status,
          "inserted_at" => event_user.inserted_at,
          "updated_at" => event_user.updated_at
        })

      json(conn |> put_status(:created), %{
        "status" => "ok",
        "user" => user
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
    event_id = Map.get(params, "event_id", "")
    user_id = Map.get(params, "id", "")

    case Calendars.get_event_user(event_id, user_id) do
      {:ok, event_user} ->
        case Calendars.update_event_user(event_user, params) do
          {:ok, event_user} ->
            user =
              event_user.user
              |> Map.from_struct()
              |> Map.take([:id, :name, :email])
              |> Map.merge(%{
                "role" => event_user.role,
                "status" => event_user.status,
                "inserted_at" => event_user.inserted_at,
                "updated_at" => event_user.updated_at
              })

            json(conn, %{"status" => "ok", "user" => user})

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

  def delete(conn, params) do
    event_id = Map.get(params, "event_id", "")
    user_id = Map.get(params, "id", "")

    case Calendars.get_event_user(event_id, user_id) do
      {:ok, event_user} ->
        Calendars.delete_event_user(event_user)
        json(conn, %{"status" => "ok", "event_user" => event_user})

      {:error, :invalid_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid id"})

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})
    end
  end
end
