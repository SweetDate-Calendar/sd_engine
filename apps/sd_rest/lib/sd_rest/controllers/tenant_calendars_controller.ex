defmodule SDRest.TenantSweetDateController do
  use SDRest, :controller
  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100
  action_fallback SDRest.FallbackController

  @doc """
  List calendars for a tenant.

  Request:
    GET /api/v1/tenants/:tenant_id/calendars?limit=...&offset=...&q=...

  Response:
    {
      "status": "ok",
      "calendars": [
        {
          "id": "00000000-0000-0000-0000-000000000000",
          "name": "Team Calendar",
          "color_theme": "blue",
          "visibility": "public",
          "inserted_at": "2025-08-18T09:20:00Z",
          "updated_at": "2025-08-19T10:15:00Z"
        }
      ]
    }

  Errors:
    404 Not Found
    {
      "status": "error",
      "message": "not found",
      "error_code": "NOT_FOUND"
    }
  """
  def index(conn, %{"tenants_id" => tenant_id} = params) do
    case SD.Tenants.get_tenant(tenant_id) do
      %{} ->
        {limit, offset} = pagination(params)
        q = Map.get(params, "q")

        tenant_calendars =
          SD.Tenants.list_tenant_calendars(tenant_id, limit: limit, offset: offset, q: q)

        calendars =
          Enum.map(tenant_calendars, fn tc ->
            c = tc.calendar

            %{
              "id" => c.id,
              "name" => c.name,
              "color_theme" => c.color_theme,
              "visibility" => to_string(c.visibility),
              "inserted_at" => c.inserted_at,
              "updated_at" => c.updated_at
            }
          end)

        json(conn, %{
          "status" => "ok",
          "calendars" => calendars
        })

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Link an existing calendar to a tenant.

  Request:
    POST /api/v1/tenants/:tenant_id/calendars
    {
      "calendar_id": "00000000-0000-0000-0000-000000000000"
    }

  Response:
    201 Created
    {
      "status": "ok",
      "calendar": {
        "id": "00000000-0000-0000-0000-000000000000",
        "name": "Team Calendar",
        "color_theme": "blue",
        "visibility": "public",
        "inserted_at": "2025-08-18T09:20:00Z",
        "updated_at": "2025-08-19T10:15:00Z"
      }
    }

  Errors:
    404 Not Found
    {
      "status": "error",
      "message": "not found",
      "error_code": "NOT_FOUND"
    }

    422 Unprocessable Entity
    {
      "status": "error",
      "message": "invalid input",
      "error_code": "VALIDATION_ERROR",
      "fields": {
        "calendar_id": ["is not a valid UUID"]
      }
    }
  """
  def create(conn, %{"tenants_id" => tenant_id} = params) do
    case SD.Tenants.get_tenant(tenant_id) do
      %{} ->
        attrs = %{
          "tenant_id" => tenant_id,
          "calendar_id" => Map.get(params, "calendar_id")
        }

        with {:ok, tenant_calendar} <- SD.Tenants.create_tenant_calendar(attrs),
             tenant_calendar <- SD.Repo.preload(tenant_calendar, :calendar) do
          cal = tenant_calendar.calendar

          json(
            put_status(conn, 201),
            %{
              "status" => "ok",
              "calendar" => %{
                "id" => cal.id,
                "name" => cal.name,
                "color_theme" => cal.color_theme,
                "visibility" => to_string(cal.visibility),
                "inserted_at" => cal.inserted_at,
                "updated_at" => cal.updated_at
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

  @doc """
  Show a single tenant calendar (by calendar id within the tenant).

  Request:
    GET /api/v1/tenants/:tenant_id/calendars/:id

  Response:
    {
      "status": "ok",
      "calendar": {
        "id": "00000000-0000-0000-0000-000000000000",
        "name": "Team Calendar",
        "color_theme": "blue",
        "visibility": "public",
        "inserted_at": "2025-08-18T09:20:00Z",
        "updated_at": "2025-08-19T10:15:00Z"
      }
    }

  Errors:
    404 Not Found
    {
      "status": "error",
      "message": "not found",
      "error_code": "NOT_FOUND"
    }
  """
  def show(conn, %{"tenants_id" => tenant_id, "id" => calendar_id}) do
    case SD.Tenants.get_tenant_calendar(tenant_id, calendar_id) do
      %SD.Tenants.TenantCalendar{} = tenant_calendar ->
        cal = tenant_calendar.calendar

        json(conn, %{
          "status" => "ok",
          "calendar" => %{
            "id" => cal.id,
            "name" => cal.name,
            "color_theme" => cal.color_theme,
            "visibility" => to_string(cal.visibility),
            "inserted_at" => cal.inserted_at,
            "updated_at" => cal.updated_at
          }
        })

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Delete a tenant calendar link.

  Request:
    DELETE /api/v1/tenants/:tenant_id/calendars/:id

  Response:
    {
      "status": "ok"
    }

  Errors:
    404 Not Found
    {
      "status": "error",
      "message": "not found",
      "error_code": "NOT_FOUND"
    }
  """
  def delete(conn, %{"tenants_id" => tenant_id, "id" => calendar_id}) do
    with %SD.Tenants.TenantCalendar{} = tenant_calendar <-
           SD.Tenants.get_tenant_calendar(tenant_id, calendar_id),
         {:ok, _} <- SD.Tenants.delete_tenant_calendar(tenant_calendar) do
      json(conn, %{"status" => "ok"})
    else
      nil ->
        {:error, :not_found}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end
end
