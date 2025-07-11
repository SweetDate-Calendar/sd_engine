defmodule ClpTcp.Handlers.PingTest do
  use ExUnit.Case, async: false

  import ClpTcp.TestHelper

  test "responds with pong on PING" do
    assert %{"status" => "ok", "message" => "pong"} =
             tcp_send("PING|" <> Jason.encode!(authorize(%{})))
  end

  test "responds with unauthorized" do
    assert %{"message" => "unauthorized", "status" => "error"} =
             tcp_send("PING|" <> Jason.encode!(%{}))
  end
end
