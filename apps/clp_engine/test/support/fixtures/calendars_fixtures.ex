defmodule CLP.CalendarsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CLP.Calendars` context.
  """

  @doc """
  Generate a calendar.
  """
  def calendar_fixture(attrs \\ %{}) do
    {:ok, calendar} =
      attrs
      |> Enum.into(%{
        color_theme: "some color_theme",
        name: "some name",
        visibility: "some visibility"
      })
      |> CLP.Calendars.create_calendar()

    calendar
  end
end
