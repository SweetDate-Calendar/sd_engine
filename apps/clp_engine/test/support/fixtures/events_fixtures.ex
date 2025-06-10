defmodule CLP.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CLP.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        all_day: true,
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
      |> CLP.Events.create_event()

    event
  end
end
