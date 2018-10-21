defmodule PackagrTest do
  use ExUnit.Case
  doctest Mix.Tasks.Packagr

  alias Mix.Tasks.Packagr

  import ExUnit.CaptureIO
  import Mox

  setup :verify_on_exit!

  describe "--version" do
    test "displays a short description and the version" do
      assert capture_io(fn -> Packagr.run(["--version"]) end) ==
               "a very simple package manager 0.0.1\n"
    end
  end

  describe "--help" do
    test "displays help text" do
      result = capture_io(fn -> Packagr.run(["--help"]) end)
      assert result =~ "a very simple package manager 0.0.1\n"
      assert result =~ "USAGE:\n"
      assert result =~ "SUBCOMMANDS:\n"
      assert result =~ "search"
      assert result =~ "publish"
      assert result =~ "install"
    end
  end

  describe "search" do
    test "displays search results" do
      expect(ApiMock, :search, fn query ->
        %{
          "packages" => [
            %{"id" => 1, "name" => query, "version" => "0.0.1"}
          ]
        }
      end)

      result = capture_io(fn -> Packagr.run(["search", "example"]) end)
      assert result =~ ~r/^example - \d+.\d+.\d+\n$/
    end
  end

  describe "publish" do
    setup do
      on_exit(fn ->
        File.rm_rf("temp/")
      end)
    end

    test "displays response" do
      expect(ApiMock, :publish, fn _filename -> :success end)

      File.mkdir("temp/")
      filepath = "temp/foo.tar.gz"
      File.write(filepath, "some gzipped data")
      result = capture_io(fn -> Packagr.run(["publish", filepath]) end)
      assert result =~ ~r/^success\n$/
    end
  end

  describe "install" do
    setup do
      on_exit(fn ->
        File.rm_rf("temp/")
      end)
    end

    test "displays message when package is installed" do
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

      result = capture_io(fn -> Packagr.run(["install", "afilename", "0.0.1"]) end)
      assert result =~ ~r/^success\n$/
    end
  end
end
