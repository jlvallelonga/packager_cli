defmodule PackagrCliTest do
  use ExUnit.Case
  doctest PackagrCli

  import ExUnit.CaptureIO

  describe "parse_arguments/1" do
    test "returns a tuple with an array and a Optimus.ParseResult struct" do
      assert {subcommands, parse_result = %Optimus.ParseResult{}} =
               PackagrCli.parse_arguments(["search", "example"])

      assert subcommands == [:search]
      assert parse_result.args == %{query: "example"}
    end
  end

  describe "search/1" do
    test "displays search results" do
      result = capture_io(fn -> PackagrCli.search(%{query: "example"}) end)
      assert result =~ ~r/^example - \d+.\d+.\d+\n$/
    end
  end

  describe "publish/1" do
    setup do
      on_exit(fn ->
        File.rm_rf("temp/")
      end)
    end

    test "displays success when it succeeds" do
      File.mkdir("temp/")
      filepath = "temp/foo.tar.gz"
      File.write(filepath, "some gzipped data")

      result = capture_io(fn -> PackagrCli.publish(%{filepath: filepath}) end)
      assert result =~ ~r/^success\n$/
    end

    test "displays error if file doesn't exist" do
      result = capture_io(fn -> PackagrCli.publish(%{filepath: "non_existent_file.tar.gz"}) end)
      assert result =~ ~r/^error\n$/
    end
  end

  describe "install/1" do
    setup do
      on_exit(fn ->
        File.rm_rf("temp/")
      end)
    end

    test "displays response" do
      result = capture_io(fn -> PackagrCli.install(%{package: "example", version: "0.0.1"}) end)
      assert result =~ ~r/^success\n$/
    end
  end
end
