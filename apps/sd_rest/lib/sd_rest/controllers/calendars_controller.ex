defmodule SDRest.CalendarsController do
  use SDRest, :controller
  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100

  alias SD.SweetDate

  # GET /api/v1/calendars?limit=25&offset=0
  def index(conn, params) do
    {limit, offset} = pagination(params)

    calendars = SweetDate.list_calendars(limit: limit, offset: offset)

    json(conn, %{
      "status" => "ok",
      "calendars" => Enum.map(calendars, &calendar_json/1),
      "limit" => limit,
      "offset" => offset
    })
  end

  # GET /api/v1/calendars/:id
  def show(conn, %{"id" => id}) do
    with :ok <- ensure_uuid(id),
         {:ok, calendar} <- fetch_calendar(id) do
      json(conn, %{
        "status" => "ok",
        "calendar" => calendar_json(calendar)
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

  # POST /api/v1/calendars
  def create(conn, params) do
    attrs = %{
      "name" => Map.get(params, "name"),
      "color_theme" => Map.get(params, "color_theme", "default"),
      "visibility" => Map.get(params, "visibility", "public")
    }

    case SweetDate.create_calendar(attrs) do
      {:ok, calendar} ->
        json(conn |> put_status(201), %{
          "status" => "ok",
          "calendar" => calendar_json(calendar)
        })

      {:error, changeset} ->
        json(conn |> put_status(422), %{
          "status" => "error",
          "message" => "validation failed",
          "details" => translate_changeset_errors(changeset)
        })
    end
  end

  # PUT /api/v1/calendars/:id
  def update(conn, %{"id" => id} = params) do
    with :ok <- ensure_uuid(id),
         {:ok, calendar} <- fetch_calendar(id),
         attrs <- Map.take(params, ["name", "color_theme", "visibility"]),
         {:ok, updated} <- SweetDate.update_calendar(calendar, attrs) do
      json(conn, %{"status" => "ok", "calendar" => calendar_json(updated)})
    else
      :error ->
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

  # DELETE /api/v1/calendars/:id
  def delete(conn, %{"id" => id}) do
    with :ok <- ensure_uuid(id),
         {:ok, calendar} <- fetch_calendar(id),
         {:ok, _} <- SweetDate.delete_calendar(calendar) do
      json(conn, %{
        "status" => "ok",
        "calendar" => %{"id" => calendar.id, "name" => calendar.name}
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

  ## --- helpers ---

  defp fetch_calendar(id) do
    case SweetDate.get_calendar(id) do
      {:ok, calendar} when not is_nil(calendar) -> {:ok, calendar}
      %{} = calendar -> {:ok, calendar}
      nil -> {:error, :not_found}
      {:error, :not_found} -> {:error, :not_found}
      other -> other
    end
  end

  defp calendar_json(calendar) do
    %{
      "id" => calendar.id,
      "name" => calendar.name,
      "color_theme" => calendar.color_theme,
      "visibility" => calendar.visibility,
      "created_at" => calendar.inserted_at,
      "updated_at" => calendar.updated_at
    }
  end
end
