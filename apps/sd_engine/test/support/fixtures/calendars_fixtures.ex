defmodule SD.CalendarsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SD.SweetDate` context.
  """

  import SD.AccountsFixtures

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    calendar_id =
      Map.get(attrs, :calendar_id) ||
        calendar_fixture().id

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

  @doc """
  Generate a tenant_calendar join.
  If `:calendar_id` or `:tenant_id` are not provided, fixtures are used.
  """
  def tenant_calendar_fixture(attrs \\ %{}) do
    calendar =
      Map.get(attrs, :calendar_id) ||
        calendar_fixture().id

    tenant =
      Map.get(attrs, :tenant_id) ||
        SD.TenantsFixtures.tenant_fixture().id

    {:ok, tenant_calendar} =
      attrs
      |> Enum.into(%{
        tenant_id: tenant,
        calendar_id: calendar
      })
      |> SD.Tenants.create_tenant_calendar()

    tenant_calendar
  end

  @doc """
  Generate a calendar_user.
  If `:calendar_id` or `:user_id` are not provided, fixtures are used.
  """
  def calendar_user_fixture(attrs \\ %{}) do
    calendar_id =
      Map.get(attrs, :calendar_id) ||
        calendar_fixture().id

    user_id =
      Map.get(attrs, :user_id) ||
        user_fixture().id

    role = Map.get(attrs, :role, "guest")

    {:ok, calendar_user} =
      attrs
      |> Enum.into(%{
        user_id: user_id,
        calendar_id: calendar_id,
        role: role
      })
      |> SD.Calendars.create_calendar_user()

    calendar_user
  end
end
