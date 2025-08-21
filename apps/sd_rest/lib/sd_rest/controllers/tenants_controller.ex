defmodule SDRest.TenantsController do
  use SDRest, :controller

  alias SD.Tenants

  @default_limit 25
  @max_limit 100

  # GET /api/v1/tenants?limit=25&offset=0
  def index(conn, params) do
    {limit, offset} = pagination(params)

    # Expecting: SD.Tenants.list_tenants(limit: ..., offset: ...)
    tenants = Tenants.list_tenants(limit: limit, offset: offset)

    json(conn, %{
      "status" => "ok",
      "result" => %{
        "tenants" => Enum.map(tenants, &tenant_json/1),
        "limit" => limit,
        "offset" => offset
      }
    })
  end

  # GET /api/v1/tenants/:id
  def show(conn, %{"id" => id}) do
    with :ok <- ensure_uuid(id),
         {:ok, tenant} <- fetch_tenant(id) do
      json(conn, %{
        "status" => "ok",
        "result" => %{"tenant" => tenant_json(tenant)}
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

  # POST /api/v1/tenants
  def create(conn, params) do
    attrs = %{
      "name" => Map.get(params, "name")
      # Include any extra attributes you accept here.
      # If you auto-create a default calendar, that likely happens in the context.
    }

    # Expecting: SD.Tenants.create_tenant(attrs) -> {:ok, tenant} | {:error, changeset}
    case Tenants.create_tenant(attrs) do
      {:ok, tenant} ->
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

  defp ensure_uuid(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _} -> :ok
      :error -> :error
    end
  end

  # Normalize various context return styles into {:ok, tenant} | {:error, :not_found}
  defp fetch_tenant(id) do
    case SD.Tenants.get_tenant(id) do
      {:ok, tenant} when not is_nil(tenant) -> {:ok, tenant}
      %{} = tenant -> {:ok, tenant}
      nil -> {:error, :not_found}
      {:error, :not_found} -> {:error, :not_found}
      other -> other
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

  defp tenant_json(t) do
    %{
      "id" => t.id,
      "name" => t.name,
      "created_at" => t.inserted_at,
      "updated_at" => t.updated_at
    }
  end

  # Minimal error translator; plug in your real Ecto changeset error translator if available.
  defp translate_changeset_errors(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {k, v}, acc -> String.replace(acc, "%{#{k}}", to_string(v)) end)
    end)
  end
end
