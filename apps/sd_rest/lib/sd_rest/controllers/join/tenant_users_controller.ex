defmodule SDRest.Join.TenantUsersController do
  use SDRest, :controller
  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100

  alias SD.Tenants

  def create(conn, params) do
    with {:ok, join} <- Tenants.create_tenant_user(params) do
      json(conn |> put_status(:created), %{
        "status" => "ok",
        "tenant_user" => join
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
    params = Map.put(params, "tenant_id", params["id"])

    case Tenants.get_tenant_user(params) do
      {:ok, tenant_user} ->
        json(conn, %{
          "status" => "ok",
          "tenant_id" => tenant_user.tenant_id,
          "user" => tenant_user.user
        })

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :invalid_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid id"})
    end
  end

  def delete(conn, params) do
    case Tenants.get_tenant_user(params) do
      {:ok, tenant_user} ->
        Tenants.delete_tenant_user(tenant_user)
        json(conn, %{"status" => "ok", "tenant_user" => tenant_user})

      {:error, :invalid_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid id"})
    end
  end
end
