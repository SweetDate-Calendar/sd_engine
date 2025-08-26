defmodule SD.SweetDateFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SD.SweetDate` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    calendar_id =
      Map.get(attrs, :calendar_id) ||
        SD.SweetDateFixtures.calendar_fixture().id

    {:ok, event} =
      attrs
      |> Enum.into(%{
        all_day: true,
        calendar_id: calendar_id,
        color_theme: "some color_theme",
        description: "some description",
        end_time: ~U[2025-06-09 17:09:00Z],
        location: "some location",
        name: "some name",
        status: :scheduled,
        recurrence_rule: :none,
        start_time: ~U[2025-06-09 17:09:00Z],
        visibility: :public
      })
      |> SD.SweetDate.create_event()

    event
  end

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

    {:ok, calendar} = SD.SweetDate.create_calendar(attrs)
    calendar
  end
end
