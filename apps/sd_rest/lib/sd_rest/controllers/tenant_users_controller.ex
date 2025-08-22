# apps/sd_rest/lib/sd_rest/controllers/tenant_users_controller.ex
defmodule SDRest.TenantUsersController do
  use SDRest, :controller

  alias SD.Tenants

  @default_limit 25
  @max_limit 100

  # GET /api/v1/tenants/:tenant_id/users?limit=25&offset=0&q=...
  def index(conn, %{"tenant_id" => tenant_id} = params) do
    with :ok <- ensure_uuid(tenant_id),
         {:ok, _tenant} <- fetch_tenant(tenant_id) do
      {limit, offset} = pagination(params)
      q = Map.get(params, "q")

      # Correct context call (scoped + paginated + optional search)
      items = Tenants.list_tenant_users(tenant_id, limit: limit, offset: offset, q: q)

      json(conn, %{
        "status" => "ok",
        "tenant_users" => Enum.map(items, &tenant_user_json/1),
        "limit" => limit,
        "offset" => offset
      })
    else
      :error ->
        json(put_status(conn, 404), %{"status" => "error", "message" => "not found"})

      {:error, :not_found} ->
        json(put_status(conn, 404), %{"status" => "error", "message" => "not found"})

      {:error, reason} ->
        json(put_status(conn, 500), %{"status" => "error", "message" => inspect(reason)})
    end
  end

  # POST /api/v1/tenants/:tenant_id/users
  # Body: { "user_id": "...", "role": "member" }
  # (If you support creating a user inline, include user fields and handle in context.)
  def create(conn, %{"tenant_id" => tenant_id} = params) do
    with :ok <- ensure_uuid(tenant_id),
         {:ok, _tenant} <- fetch_tenant(tenant_id),
         attrs <- Map.take(params, ["user_id", "role"]),
         {:ok, membership} <- Tenants.add_user(tenant_id, attrs) do
      json(conn |> put_status(201), %{
        "status" => "ok",
        "tenant_user" => tenant_user_json(membership)
      })
    else
      :error ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        json(conn |> put_status(422), %{
          "status" => "error",
          "message" => "validation failed",
          "details" => translate_changeset_errors(cs)
        })

      {:error, reason} ->
        json(conn |> put_status(500), %{"status" => "error", "message" => inspect(reason)})
    end
  end

  # GET /api/v1/tenants/:tenant_id/users/:id
  # GET /api/v1/tenants/:tenant_id/users/:id
  def show(conn, %{"tenant_id" => tenant_id, "id" => user_id}) do
    case Tenants.get_tenant_user(tenant_id, user_id) do
      %SD.Users.User{} = user ->
        json(conn, %{
          "status" => "ok",
          "user" => user_json(user)
        })

      nil ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})
    end
  end

  # PUT /api/v1/tenants/:tenant_id/users/:id
  # Body: { "role": "owner" }
  def update(conn, %{"tenant_id" => tenant_id, "id" => id} = params) do
    with :ok <- ensure_uuid(tenant_id),
         :ok <- ensure_uuid(id),
         {:ok, _tenant} <- fetch_tenant(tenant_id),
         {:ok, membership} <- fetch_membership(tenant_id, id),
         attrs <- Map.take(params, ["role"]),
         {:ok, updated} <- Tenants.update_tenant_user(membership, attrs) do
      json(conn, %{
        "status" => "ok",
        "tenant_user" => tenant_user_json(updated)
      })
    else
      :error ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        json(conn |> put_status(422), %{
          "status" => "error",
          "message" => "validation failed",
          "details" => translate_changeset_errors(cs)
        })

      {:error, reason} ->
        json(conn |> put_status(500), %{"status" => "error", "message" => inspect(reason)})
    end
  end

  # DELETE /api/v1/tenants/:tenant_id/users/:id
  def delete(conn, %{"tenant_id" => tenant_id, "id" => id}) do
    with :ok <- ensure_uuid(tenant_id),
         :ok <- ensure_uuid(id),
         {:ok, _tenant} <- fetch_tenant(tenant_id),
         {:ok, membership} <- fetch_membership(tenant_id, id),
         {:ok, _} <- Tenants.delete_tenant_user(membership) do
      json(conn, %{
        "status" => "ok",
        "tenant_user" => %{"id" => membership.id}
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

  ## ---- helpers --------------------------------------------------------

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

  defp translate_changeset_errors(cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {k, v}, acc ->
        String.replace(acc, "%{#{k}}", to_string(v))
      end)
    end)
  end

  # Treat invalid UUIDs as not found (avoids Ecto cast exceptions leaking)
  defp ensure_uuid(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _} -> :ok
      :error -> :error
    end
  end

  # Normalize tenant fetch result to {:ok, tenant} | {:error, :not_found}
  defp fetch_tenant(id) do
    case Tenants.get_tenant(id) do
      {:ok, t} when not is_nil(t) -> {:ok, t}
      %{} = t -> {:ok, t}
      nil -> {:error, :not_found}
      {:error, :not_found} -> {:error, :not_found}
      other -> other
    end
  end

  # Normalize membership fetch result to {:ok, membership} | nil
  defp fetch_membership(tenant_id, id) do
    case SD.Tenants.get_tenant_user(tenant_id, id) do
      %SD.Users.User{} = user -> user
      nil -> {:error, :not_found}
    end
  end

  defp tenant_user_json(tu) do
    %{
      "id" => tu.id,
      "tenant_id" => tu.tenant_id,
      "user_id" => tu.user_id,
      "role" => tu.role,
      "created_at" => tu.inserted_at,
      "updated_at" => tu.updated_at
    }
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
