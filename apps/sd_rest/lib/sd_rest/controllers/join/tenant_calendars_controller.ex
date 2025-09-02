defmodule SDRest.Join.TenantCalendarsController do
  use SDRest, :controller

  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100

  alias SD.Tenants

  def create(conn, params) do
    with {:ok, join} <- Tenants.create_tenant_calendar(params) do
      json(conn |> put_status(:created), %{
        "status" => "ok",
        "tenant_calendar" => join
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

  def delete(conn, %{"id" => id}) do
    case Tenants.delete_tenant_calendar(id) do
      {:ok, join} ->
        json(conn, %{"status" => "ok", "tenant_calendar" => join})

      {:error, :not_found} ->
        json(conn |> put_status(:not_found), %{
          "status" => "error",
          "message" => "not found"
        })
    end
  end
end
