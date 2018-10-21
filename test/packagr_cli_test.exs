defmodule PackagrCliTest do
  use ExUnit.Case
  doctest PackagrCli

  import ExUnit.CaptureIO
  import Mox

  setup :verify_on_exit!

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
      expect(ApiMock, :search, fn "example" ->
        %{
          "packages" => [
            %{"id" => 1, "name" => "example", "version" => "0.0.1"}
          ]
        }
      end)
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
      filepath = "temp/foo.tar.gz"
      expect(ApiMock, :publish, fn ^filepath -> :success end)

      File.mkdir("temp/")
      File.write(filepath, "some gzipped data")

      result = capture_io(fn -> PackagrCli.publish(%{filepath: filepath}) end)
      assert result =~ ~r/^success\n$/
    end

    test "displays error if file doesn't exist" do
      filepath = "non_existent_file.tar.gz"
      expect(ApiMock, :publish, 0, fn ^filepath -> :success end)

      result = capture_io(fn -> PackagrCli.publish(%{filepath: filepath}) end)
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
      expect(ApiMock, :install, fn package_name, version ->
        File.mkdir("temp/")

        files = [
          {'example/example.js', "console.log(\"this is an example package\");\n"},
          {'example/packagr.yml', "name: #{package_name}\nversion: #{version}\n"}
        ]

        :erl_tar.create("temp/package.tar.gz", files, [:compressed])

        {:ok, package_gzipped_data} = File.read("temp/package.tar.gz")
        package_gzipped_data
      end)

      result = capture_io(fn -> PackagrCli.install(%{package: "example", version: "0.0.1"}) end)
      assert result =~ ~r/^success\n$/
    end
  end
end
