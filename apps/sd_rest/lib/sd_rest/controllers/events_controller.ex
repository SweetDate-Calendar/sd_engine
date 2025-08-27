defmodule SDRest.EventsController do
  use SDRest, :controller
  use SDRest.ControllerHelpers, default_limit: 25, max_limit: 100

  alias SD.SweetDate

  # GET /api/v1/calendars/:calendar_id/events
  def index(conn, %{"calendars_id" => calendar_id} = params) do
    {limit, offset} = pagination(params)

    events =
      SweetDate.list_events(calendar_id,
        limit: limit,
        offset: offset
      )

    json(conn, %{
      "status" => "ok",
      "result" => %{
        "events" => Enum.map(events, &event_json/1),
        "limit" => limit,
        "offset" => offset
      }
    })
  end

  # GET /api/v1/calendars/:calendar_id/events/:id
  def show(conn, %{"id" => id}) do
    case SweetDate.get_event(id) do
      nil ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      event ->
        json(conn, %{
          "status" => "ok",
          "result" => %{"event" => event_json(event)}
        })
    end
  end

  # POST /api/v1/calendars/:calendars_id/events
  def create(conn, %{"calendars_id" => calendar_id} = params) do
    attrs = Map.put(params, "calendar_id", calendar_id)

    case SweetDate.create_event(attrs) do
      {:ok, event} ->
        json(conn |> put_status(201), %{
          "status" => "ok",
          "event" => event_json(event)
        })

      {:error, changeset} ->
        json(conn |> put_status(422), %{
          "status" => "error",
          "message" => "validation failed",
          "details" => translate_changeset_errors(changeset)
        })
    end
  end

  # PUT /api/v1/calendars/:calendar_id/events/:id
  def update(conn, %{"id" => id} = params) do
    case SweetDate.get_event(id) do
      nil ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      event ->
        case SweetDate.update_event(event, Map.drop(params, ["id", "calendar_id"])) do
          {:ok, updated} ->
            json(conn, %{"status" => "ok", "event" => event_json(updated)})

          {:error, changeset} ->
            json(conn |> put_status(422), %{
              "status" => "error",
              "message" => "invalid input",
              "details" => translate_changeset_errors(changeset)
            })
        end
    end
  end

  # DELETE /api/v1/calendars/:calendar_id/events/:id
  def delete(conn, %{"id" => id}) do
    case SweetDate.get_event(id) do
      nil ->
        json(conn |> put_status(404), %{"status" => "error", "message" => "not found"})

      event ->
        {:ok, _} = SweetDate.delete_event(event)

        json(conn, %{
          "status" => "ok",
          "event" => %{"id" => event.id, "name" => event.name}
        })
    end
  end

  ## --- Helpers ---

  defp event_json(event) do
    %{
      "id" => event.id,
      "name" => event.name,
      "calendar_id" => event.calendar_id,
      "start_time" => event.start_time,
      "end_time" => event.end_time,
      "status" => event.status,
      "visibility" => event.visibility,
      "location" => event.location,
      "color_theme" => event.color_theme,
      "all_day" => event.all_day,
      "recurrence_rule" => event.recurrence_rule,
      "description" => event.description,
      "created_at" => event.inserted_at,
      "updated_at" => event.updated_at
    }
  end
end
