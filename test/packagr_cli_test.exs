defmodule PackagrCliTest do
  use ExUnit.Case
  doctest PackagrCli

  test "greets the world" do
    assert PackagrCli.hello() == :world
  end
end
