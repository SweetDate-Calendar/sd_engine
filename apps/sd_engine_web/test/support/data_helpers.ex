defmodule SDWeb.Test.DateHelpers do
  @doc "Format DateTime for datetime-local inputs"
  def to_local(%DateTime{} = dt) do
    dt
    |> DateTime.to_naive()
    # consistent precision
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.to_string()
    |> String.slice(0, 16)
    |> String.replace(" ", "T")
  end

  @doc "Return {start_time, end_time} formatted for datetime-local"
  def local_window_minutes(from_min \\ 0, dur_min \\ 60) do
    now = DateTime.utc_now() |> DateTime.add(from_min * 60, :second)
    later = DateTime.add(now, dur_min * 60, :second)
    {to_local(now), to_local(later)}
  end
end
