defmodule SDTCP.Handlers.Calendars do
  import SDTCP.Handlers.Helpers, only: [format_errors: 1]

  def dispatch("LIST", _params) do
    %{status: "ok", calendars: SD.Calendars.list_calendars()}
  end

  def dispatch("CREATE", %{"name" => _name, "tenant_id" => _tenant_id} = attrs) do
    case SD.Calendars.create_calendar(attrs) do
      {:ok, %SD.Calendars.Calendar{} = calendar} ->
        %{status: "ok", calendar: calendar}

      {:error, changeset} ->
        %{status: "error", message: format_errors(changeset.errors)}
    end
  end

  def dispatch("GET", %{"id" => id}) do
    case SD.Calendars.get_calendar(id) do
      %SD.Calendars.Calendar{} = calendar ->
        %{status: "ok", calendar: calendar}

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch("UPDATE", %{"id" => id} = attrs) do
    case SD.Calendars.get_calendar(id) do
      %SD.Calendars.Calendar{} = calendar ->
        case SD.Calendars.update_calendar(calendar, attrs) do
          {:ok, updated} -> %{status: "ok", calendar: updated}
          {:error, changeset} -> %{status: "error", message: format_errors(changeset.errors)}
        end

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch("DELETE", %{"id" => id}) do
    case SD.Calendars.get_calendar(id) do
      %SD.Calendars.Calendar{} = calendar ->
        case SD.Calendars.delete_calendar(calendar) do
          {:ok, _} -> %{status: "ok"}
          {:error, _} -> %{status: "error", message: "failed to delete"}
        end

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch(_, _), do: %{status: "error", message: "invalid command or payload"}
end
