defmodule SDRest.Join.TenantCalendarsController do
  use SDRest, :controller

  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100

  alias SD.Tenants

  def create(conn, params) do
    case Tenants.create_tenant_calendar(params) do
      {:ok, tenant_calendar} ->
        tenant_calendar = SD.Repo.preload(tenant_calendar, :calendar)

        json(conn |> put_status(:created), %{
          "status" => "ok",
          "calendar" => tenant_calendar.calendar
        })

      {:error, changeset} ->
        json(conn |> put_status(:unprocessable_entity), %{
          "status" => "error",
          "message" => translate_changeset_errors(changeset)
        })
    end
  end

  def delete(conn, params) do
    tenant_id = Map.get(params, "tenant_id", "")
    calendar_id = Map.get(params, "id", "")

    case Tenants.get_tenant_calendar(tenant_id, calendar_id) do
      {:ok, tenant_calendar} ->
        SD.Tenants.delete_tenant_calendar(tenant_calendar)
        json(conn, %{"status" => "ok"})

      {:error, :invalid_tenant_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid tenant_id"})

      {:error, :invalid_calendar_id} ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "invalid calendar_id"})

      _ ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})
    end
  end
end
