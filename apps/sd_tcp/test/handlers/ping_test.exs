defmodule SDTCP.Handlers.PingTest do
  use ExUnit.Case, async: false

  import SDTCP.TestHelper

  test "responds with pong on PING" do
    assert %{"status" => "ok", "message" => "pong"} =
             sd_send("PING|" <> Jason.encode!(authorize(%{})))
  end

  test "responds with unauthorized" do
    assert %{"message" => "unauthorized", "status" => "error"} =
             sd_send("PING|" <> Jason.encode!(%{}))
  end
end
