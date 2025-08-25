defmodule SDTCP.Handlers.SweetDate do
  import SDTCP.Handlers.Helpers, only: [format_errors: 1]

  def dispatch("LIST", _params) do
    %{status: "ok", calendars: SD.SweetDate.list_calendars()}
  end

  def dispatch("CREATE", %{"name" => _name} = attrs) do
    case SD.SweetDate.create_calendar(attrs) do
      {:ok, %SD.SweetDate.Calendar{} = calendar} ->
        %{status: "ok", calendar: calendar}

      {:error, changeset} ->
        %{status: "error", message: format_errors(changeset.errors)}
    end
  end

  def dispatch("GET", %{"id" => id}) do
    case SD.SweetDate.get_calendar(id) do
      %SD.SweetDate.Calendar{} = calendar ->
        %{status: "ok", calendar: calendar}

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch("UPDATE", %{"id" => id} = attrs) do
    case SD.SweetDate.get_calendar(id) do
      %SD.SweetDate.Calendar{} = calendar ->
        case SD.SweetDate.update_calendar(calendar, attrs) do
          {:ok, updated} -> %{status: "ok", calendar: updated}
          {:error, changeset} -> %{status: "error", message: format_errors(changeset.errors)}
        end

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch("DELETE", %{"id" => id}) do
    case SD.SweetDate.get_calendar(id) do
      %SD.SweetDate.Calendar{} = calendar ->
        case SD.SweetDate.delete_calendar(calendar) do
          {:ok, _} -> %{status: "ok"}
          {:error, _} -> %{status: "error", message: "failed to delete"}
        end

      nil ->
        %{status: "error", message: "not found"}
    end
  end

  def dispatch(_, _), do: %{status: "error", message: "invalid command or payload"}
end
