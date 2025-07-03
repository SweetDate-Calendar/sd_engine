defmodule CLP.CalendarsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CLP.Calendars` context.
  """

  @doc """
  Generate a calendar.
  """
  def calendar_fixture(attrs \\ %{}) do
    attrs =
      case Map.get(attrs, :tier_id) do
        nil ->
          %{id: tier_id} = CLP.TiersFixtures.tier_fixture()

          Map.put(attrs, :tier_id, tier_id)

        _ ->
          attrs
      end

    attrs =
      attrs
      |> Enum.into(%{
        color_theme: "some color_theme",
        name: "some name",
        visibility: :public
      })

    {:ok, calendar} = CLP.Calendars.create_calendar(attrs)
    calendar
  end
end
