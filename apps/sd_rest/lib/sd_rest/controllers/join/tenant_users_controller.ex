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

  def update(conn, %{"id" => id} = params) do
    case Tenants.update_tenant_user(id, params) do
      {:ok, join} ->
        json(conn, %{"status" => "ok", "tenant_user" => join})

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
    case Tenants.delete_tenant_user(id) do
      {:ok, join} ->
        json(conn, %{"status" => "ok", "tenant_user" => join})

      {:error, :not_found} ->
        json(conn |> put_status(:not_found), %{
          "status" => "error",
          "message" => "not found"
        })
    end
  end
end
