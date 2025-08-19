defmodule SD_RESTTest do
  use ExUnit.Case
  doctest SD_REST

  test "greets the world" do
    assert SD_REST.hello() == :world
  end
end
