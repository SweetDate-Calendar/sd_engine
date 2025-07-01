defmodule ClpTcp.Handlers.PingTest do
  use ExUnit.Case, async: false

  alias ClpTcp.TestHelper

  test "responds with pong on PING" do
    assert %{"status" => "ok", "message" => "pong"} = TestHelper.tcp_send("PING")
  end
end
