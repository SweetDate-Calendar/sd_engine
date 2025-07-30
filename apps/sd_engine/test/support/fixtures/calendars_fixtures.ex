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
