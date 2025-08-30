defmodule SDRest.TenantsController do
  use SDRest, :controller
  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100

  alias SD.Tenants

  defp broadcast_tenant(event, tenant) do
    Phoenix.PubSub.broadcast(SD.PubSub, "tenants", %Phoenix.Socket.Broadcast{
      topic: "tenants",
      event: event,
      payload: tenant
    })
  end

  # GET /api/v1/tenants?limit=25&offset=0
  def index(conn, params) do
    {limit, offset} = pagination(params)

    tenants = Tenants.list_tenants(limit: limit, offset: offset)

    json(conn, %{
      "status" => "ok",
      "tenants" => Enum.map(tenants, &tenant_json/1),
      "limit" => limit,
      "offset" => offset
    })
  end

  # GET /api/v1/tenants/:id
  def show(conn, %{"id" => id}) do
    with :ok <- ensure_uuid(id),
         {:ok, tenant} <- fetch_tenant(id) do
      json(conn, %{
        "status" => "ok",
        "tenant" => tenant_json(tenant)
      })
    else
      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, reason} ->
        json(conn |> put_status(500), %{"status" => "error", "message" => inspect(reason)})
    end
  end

  # POST /api/v1/tenants
  def create(conn, params) do
    attrs = %{
      "name" => Map.get(params, "name")
    }

    case Tenants.create_tenant(attrs) do
      {:ok, tenant} ->
        broadcast_tenant("created", tenant)

        json(conn |> put_status(201), %{
          "status" => "ok",
          "tenant" => tenant_json(tenant)
        })

      {:error, changeset} ->
        json(conn |> put_status(422), %{
          "status" => "error",
          "message" => "validation failed",
          "details" => translate_changeset_errors(changeset)
        })
    end
  end

  # PUT /api/v1/tenants/:id
  # PUT /api/v1/tenants/:id
  def update(conn, %{"id" => id} = params) do
    with :ok <- ensure_uuid(id),
         {:ok, tenant} <- fetch_tenant(id),
         attrs <- Map.take(params, ["name"]),
         {:ok, updated} <- SD.Tenants.update_tenant(tenant, attrs) do
      broadcast_tenant("updated", updated)
      json(conn, %{"status" => "ok", "tenant" => tenant_json(updated)})
    else
      :error ->
        # invalid UUID (treat same as not found to avoid leaking details)
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, %Ecto.Changeset{} = cs} ->
        json(conn |> put_status(422), %{
          "status" => "error",
          "message" => "not found or invalid input",
          "details" => translate_changeset_errors(cs)
        })

      {:error, reason} ->
        json(conn |> put_status(500), %{"status" => "error", "message" => inspect(reason)})
    end
  end

  # DELETE /api/v1/tenants/:id
  def delete(conn, %{"id" => id}) do
    with :ok <- ensure_uuid(id),
         {:ok, tenant} <- fetch_tenant(id),
         {:ok, _} <- SD.Tenants.delete_tenant(tenant) do
      broadcast_tenant("deleted", tenant)

      json(conn, %{
        "status" => "ok",
        "tenant" => %{"id" => tenant.id, "name" => tenant.name}
      })
    else
      :error ->
        # invalid UUID or failed check
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, reason} ->
        json(conn |> put_status(500), %{"status" => "error", "message" => inspect(reason)})
    end
  end

  ## --- helpers ---

  # Normalize various context return styles into {:ok, tenant} | {:error, :not_found}
  defp fetch_tenant(id) do
    case SD.Tenants.get_tenant(id) do
      {:ok, tenant} when not is_nil(tenant) -> {:ok, tenant}
      %{} = tenant -> {:ok, tenant}
      nil -> {:error, :not_found}
      {:error, :not_found} -> {:error, :not_found}
      _ -> {:error, :not_found}
    end
  end

  defp tenant_json(t) do
    %{
      "id" => t.id,
      "name" => t.name,
      "created_at" => t.inserted_at,
      "updated_at" => t.updated_at
    }
  end
end
