defmodule SD.CalendarsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SD.Calendars` context.
  """

  @doc """
  Generate a calendar.
  """
  def calendar_fixture(attrs \\ %{}) do
    attrs =
      case Map.get(attrs, :tenant_id) do
        nil ->
          %{id: tenant_id} = SD.TenantsFixtures.tenant_fixture()

          Map.put(attrs, :tenant_id, tenant_id)

        _ ->
          attrs
      end

    attrs =
      attrs
      |> Enum.into(%{
        color_theme: "some color_theme",
        name: "some name#{System.unique_integer()}",
        visibility: :public
      })

    {:ok, calendar} = SD.Calendars.create_calendar(attrs)
    calendar
  end
end
