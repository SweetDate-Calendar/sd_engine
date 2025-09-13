defmodule SDRest.UsersController do
  use SDRest, :controller
  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100

  alias SD.Accounts

  defp broadcast_user(event, user) do
    Phoenix.PubSub.broadcast(SD.PubSub, "users", %Phoenix.Socket.Broadcast{
      topic: "users",
      event: event,
      payload: user
    })
  end

  # GET /api/v1/users?limit=25&offset=0
  def index(conn, params) do
    {limit, offset} = pagination(params)

    users = Accounts.list_users(limit: limit, offset: offset)

    json(conn, %{
      "status" => "ok",
      "users" => Enum.map(users, &user_json/1),
      "limit" => limit,
      "offset" => offset
    })
  end

  # GET /api/v1/users/:id
  def show(conn, %{"id" => id}) do
    with :ok <- ensure_uuid(id),
         {:ok, user} <- fetch_user(id) do
      json(conn, %{
        "status" => "ok",
        "user" => user_json(user)
      })
    else
      :error ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, reason} ->
        json(conn |> put_status(500), %{"status" => "error", "message" => inspect(reason)})
    end
  end

  # POST /api/v1/users
  def create(conn, params) do
    attrs = %{
      "name" => Map.get(params, "name"),
      "email" => Map.get(params, "email")
    }

    case Accounts.create_user(attrs) do
      {:ok, user} ->
        broadcast_user("created", user)

        json(conn |> put_status(201), %{
          "status" => "ok",
          "user" => user_json(user)
        })

      {:error, changeset} ->
        json(conn |> put_status(422), %{
          "status" => "error",
          "message" => translate_changeset_errors(changeset)
        })
    end
  end

  # PUT /api/v1/users/:id
  def update(conn, %{"id" => id} = params) do
    with :ok <- ensure_uuid(id),
         {:ok, user} <- fetch_user(id),
         attrs <- Map.take(params, ["name", "email"]),
         {:ok, updated} <- Accounts.update_user(user, attrs) do
      broadcast_user("updated", updated)
      json(conn, %{"status" => "ok", "user" => user_json(updated)})
    else
      :error ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, %Ecto.Changeset{} = changeset} ->
        json(conn |> put_status(422), %{
          "status" => "error",
          "message" => translate_changeset_errors(changeset)
        })

      {:error, reason} ->
        json(conn |> put_status(500), %{"status" => "error", "message" => inspect(reason)})
    end
  end

  # DELETE /api/v1/users/:id
  def delete(conn, %{"id" => id}) do
    with :ok <- ensure_uuid(id),
         {:ok, user} <- fetch_user(id),
         {:ok, _} <- Accounts.delete_user(user) do
      broadcast_user("deleted", user)

      json(conn, %{
        "status" => "ok",
        "user" => %{
          "id" => user.id,
          "name" => user.name,
          "email" => user.email
        }
      })
    else
      :error ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, reason} ->
        json(conn |> put_status(500), %{"status" => "error", "message" => inspect(reason)})
    end
  end

  # Normalize context return into {:ok, user} | {:error, :not_found}
  defp fetch_user(id) do
    case Accounts.get_user(id) do
      {:ok, u} when not is_nil(u) -> {:ok, u}
      %{} = u -> {:ok, u}
      nil -> {:error, :not_found}
      {:error, :not_found} -> {:error, :not_found}
      other -> other
    end
  end

  defp user_json(u) do
    %{
      "id" => u.id,
      "name" => u.name,
      "email" => u.email,
      "created_at" => u.inserted_at,
      "updated_at" => u.updated_at
    }
  end
end
