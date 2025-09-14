defmodule SDRest.Join.TenantUsersController do
  use SDRest, :controller
  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100

  alias SD.Tenants

  def create(conn, params) do
    with {:ok, tenant_user} <- Tenants.create_tenant_user(params) do
      user =
        tenant_user.user
        |> Map.from_struct()
        |> Map.take([:id, :email, :name])
        |> Map.merge(%{
          "role" => tenant_user.role,
          "inserted_at" => tenant_user.inserted_at,
          "updated_at" => tenant_user.updated_at
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
    tenant_id = Map.get(params, "tenant_id", "")
    user_id = Map.get(params, "id", "")

    case Tenants.get_tenant_user(tenant_id, user_id) do
      {:ok, tenant_user} ->
        case Tenants.update_tenant_user(tenant_user, params) do
          {:ok, tenant_user} ->
            json(conn, %{
              "status" => "ok",
              "user" =>
                tenant_user.user
                |> Map.from_struct()
                |> Map.take([:id, :name, :email])
                |> Map.merge(%{
                  "role" => tenant_user.role,
                  "inserted_at" => tenant_user.inserted_at,
                  "updated_at" => tenant_user.updated_at
                })
            })

          {:error, message} ->
            json(conn |> put_status(404), %{
              "status" => "error",
              "message" => message
            })
        end

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      {:error, :invalid_tenant_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid tenant id"})

      {:error, :invalid_user_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid user id"})
    end
  end

  def delete(conn, params) do
    tenant_id = Map.get(params, "tenant_id", "")
    user_id = Map.get(params, "id", "")

    case Tenants.get_tenant_user(tenant_id, user_id) do
      {:ok, tenant_user} ->
        Tenants.delete_tenant_user(tenant_user)
        json(conn, %{"status" => "ok"})

      {:error, :invalid_tenant_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "tenant id"})

      {:error, :invalid_user_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid user id"})

      {:error, :not_found} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})
    end
  end
end
