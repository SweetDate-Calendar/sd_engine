defmodule SDTCP.Handlers.Calendars do
  def dispatch("LIST", %{"tier_id" => tier_id}) do
    %{status: "ok", calendars: SD.Tiers.list_calendars(tier_id)}
  end

  def dispatch("CREATE", attrs) do
    case SD.Calendars.create_calendar(attrs) do
      {:ok, calendar} ->
        Phoenix.PubSub.broadcast(
          SD.PubSub,
          "tier:#{calendar.tier_id}",
          {:calendar_created, %{calendar: calendar}}
        )

        %{status: "ok", id: calendar.id}

      {:error, cs} ->
        %{status: "error", errors: cs.errors}
    end
  end

  def dispatch("GET", attrs) do
    case attrs do
      %{"id" => id} ->
        case SD.Calendars.get_calendar(id) do
          %SD.Calendars.Calendar{} = calendar ->
            %{
              status: "ok",
              calendar: %{
                "id" => calendar.id,
                "name" => calendar.name,
                "visibility" => calendar.visibility,
                "color_theme" => calendar.color_theme
              }
            }

          nil ->
            %{status: "error", message: "not found"}
        end

      _ ->
        %{status: "error", message: "invalid json"}
    end
  end

  def dispatch("UPDATE", attrs) do
    with %SD.Calendars.Calendar{} = calendar <- SD.Calendars.get_calendar(attrs["id"]),
         {:ok, calendar} <- SD.Calendars.update_calendar(calendar, attrs) do
      Phoenix.PubSub.broadcast(
        SD.PubSub,
        "account:#{calendar.tier_id}",
        {:calendar_updated, %{calendar: calendar}}
      )

      %{status: "ok", message: "calendar updated"}
    else
      _ -> %{status: "error", message: "not found or failed to update"}
    end
  end

  def dispatch("DELETE", %{"id" => id}) do
    with cal <- SD.Calendars.get_calendar(id),
         {:ok, _} <- SD.Calendars.delete_calendar(cal) do
      %{status: "ok", message: "calendar deleted"}
    else
      _ -> %{status: "error", message: "not found or failed to delete"}
    end
  end
end
