defmodule SDRest.TenantUsersController do
  use SDRest, :controller
  action_fallback SDRest.FallbackController

  @default_limit 25
  @max_limit 100

  # GET /api/v1/tenants/:tenants_id/users?limit=...&offset=...&q=...
  # Example response:
  #   {
  #     "status": "ok",
  #     "users": [
  #       {
  #         "email": "some-email@example.com",
  #         "id": "00000000-0000-0000-0000-000000000000",
  #         "inserted_at": "2025-08-18T09:20:00Z",
  #         "name": "some name",
  #         "role": "owner",
  #         "updated_at": "2025-08-19T10:15:00Z"
  #       },
  #       {
  #         "email": "some-other-email@example.com",
  #         "id": "00000000-0000-0000-0000-000000000000",
  #         "inserted_at": "2025-08-18T09:20:00Z",
  #         "name": "Some other name",
  #         "role": "admin",
  #         "updated_at": "2025-08-19T10:15:00Z"
  #       }
  #     ]
  #   }
  #
  # Error response:
  #   {
  #     "message": "...",
  #     "status": "error"
  #   }     */
  # GET /api/v1/tenants/:tenants_id/users?limit=...&offset=...&q=...
  def index(conn, %{"tenants_id" => tenant_id} = params) do
    case SD.Tenants.get_tenant(tenant_id) do
      %{} ->
        {limit, offset} = pagination(params)
        q = Map.get(params, "q")

        tenant_users =
          SD.Tenants.list_tenant_users(tenant_id, limit: limit, offset: offset, q: q)

        users =
          Enum.map(tenant_users, fn tu ->
            u = tu.user

            %{
              "id" => u.id,
              "name" => u.name,
              "email" => u.email,
              "role" => to_string(tu.role),
              "inserted_at" => u.inserted_at,
              "updated_at" => u.updated_at
            }
          end)

        json(conn, %{
          "status" => "ok",
          "tenant_id" => tenant_id,
          "users" => users
        })

      _ ->
        json(put_status(conn, 404), %{"status" => "error", "message" => "not found"})
    end
  end

  # POST /api/v1/tenants/:tenants_id/users
  # Response:
  #   {
  #     "status": "ok",
  #     "user": {
  #       "email": "some-name@example.com",
  #       "id": "00000000-0000-0000-0000-000000000000",
  #       "inserted_at": "2025-08-18T09:20:00Z",
  #       "name": "some name",
  #       "role": "admin",
  #       "updated_at": "2025-08-19T10:15:00Z"
  #     }
  #   }
  # SD.Tenants
  def create(conn, %{"tenants_id" => tenant_id} = params) do
    case SD.Tenants.get_tenant(tenant_id) do
      %{} ->
        attrs = %{
          "tenant_id" => tenant_id,
          "user_id" => Map.get(params, "user_id"),
          "role" => Map.get(params, "role", "guest")
        }

        with {:ok, tenant_user} <- SD.Tenants.create_tenant_user(attrs),
             tenant_user <- SD.Repo.preload(tenant_user, :user) do
          user = tenant_user.user

          json(
            put_status(conn, 201),
            %{
              "status" => "ok",
              "user" => %{
                "id" => user.id,
                "name" => user.name,
                "email" => user.email,
                "role" => to_string(tenant_user.role),
                "inserted_at" => user.inserted_at,
                "updated_at" => user.updated_at
              }
            }
          )
        else
          {:error, %Ecto.Changeset{} = changeset} ->
            {:error, changeset}
        end

      _ ->
        {:error, :not_found}
    end
  end

  # GET /api/v1/tenants/:tenants_id/users/:id
  # Response:
  # {
  #   "status": "ok",
  #   "user": {
  #     "id": "00000000-0000-0000-0000-000000000000",
  #     "name": "Some name",
  #     "email": "some-name@example.com",
  #     "role": "owner",
  #     "inserted_at": "2025-08-18T09:20:00Z",
  #     "updated_at": "2025-08-19T10:15:00Z"
  #   }
  # }
  def show(conn, %{"tenants_id" => tenant_id, "id" => user_id}) do
    case SD.Tenants.get_tenant_user(tenant_id, user_id) do
      %SD.Tenants.TenantUser{} = tenant_user ->
        user = tenant_user.user

        json(conn, %{
          "status" => "ok",
          "user" => %{
            "id" => user.id,
            "name" => user.name,
            "email" => user.email,
            "role" => to_string(tenant_user.role),
            "inserted_at" => user.inserted_at,
            "updated_at" => user.updated_at
          }
        })

      _ ->
        json(put_status(conn, 404), %{"status" => "error", "message" => "not found"})
    end
  end

  @doc """
  Update a tenant user.

  Request:
    PUT /api/v1/tenants/:tenant_id/users/:id
    {
      "role": "admin"
    }

  Response:
    {
      "status": "ok",
      "user": {
        "id": "00000000-0000-0000-0000-000000000000",
        "name": "Some name",
        "email": "some-name@example.com",
        "role": "admin",
        "inserted_at": "2025-08-18T09:20:00Z",
        "updated_at": "2025-08-19T10:15:00Z"
      }
    }

  Error:
    { "status": "error", "message": "..." }
  """
  def update(conn, %{"tenants_id" => tenant_id, "id" => user_id} = params) do
    with %SD.Tenants.TenantUser{} = tenant_user <- SD.Tenants.get_tenant_user(tenant_id, user_id),
         attrs <- Map.take(params, ["role"]),
         {:ok, tenant_user} <- SD.Tenants.update_tenant_user(tenant_user, attrs),
         tenant_user <- SD.Repo.preload(tenant_user, :user) do
      user = tenant_user.user

      json(conn, %{
        "status" => "ok",
        "user" => %{
          "id" => user.id,
          "name" => user.name,
          "email" => user.email,
          "role" => to_string(tenant_user.role),
          "inserted_at" => user.inserted_at,
          "updated_at" => user.updated_at
        }
      })
    else
      nil ->
        {:error, :not_found}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Delete a tenant user.

  Request:
    DELETE /api/v1/tenants/:tenant_id/users/:id

  Response:
    {
      "status": "ok"
    }

  Error:
    {
      "status": "error",
      "message": "not found"
    }
  """
  def delete(conn, %{"tenants_id" => tenant_id, "id" => user_id}) do
    with %SD.Tenants.TenantUser{} = tenant_user <- SD.Tenants.get_tenant_user(tenant_id, user_id),
         {:ok, _deleted} <- SD.Tenants.delete_tenant_user(tenant_user) do
      json(conn, %{"status" => "ok"})
    else
      nil ->
        {:error, :not_found}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  defp pagination(params) do
    limit = params |> Map.get("limit") |> parse_int(@default_limit) |> clamp(1, @max_limit)
    offset = params |> Map.get("offset") |> parse_int(0) |> max(0)
    {limit, offset}
  end

  defp parse_int(nil, default), do: default
  defp parse_int(v, _default) when is_integer(v), do: v

  defp parse_int(v, default) when is_binary(v) do
    case Integer.parse(v) do
      {i, _} -> i
      :error -> default
    end
  end

  defp clamp(i, min, max) when is_integer(i), do: i |> max(min) |> min(max)
end
