defmodule Mix.Tasks.PackagrTest do
  use FileCase, async: true
  doctest Mix.Tasks.Packagr

  import ExUnit.CaptureIO
  import Mox

  setup :verify_on_exit!

  describe "--version" do
    test "displays a short description and the version" do
      assert capture_io(fn -> Mix.Tasks.Packagr.run(["--version"]) end) ==
               "a very simple package manager 0.0.1\n"
    end
  end

  describe "--help" do
    test "displays help text" do
      result = capture_io(fn -> Mix.Tasks.Packagr.run(["--help"]) end)
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
      query = "example"
      expect(Packagr.ApiMock, :search, fn ^query ->
        %{
          "packages" => [
            %{"id" => 1, "name" => query, "version" => "0.0.1"}
          ]
        }
      end)

      result = capture_io(fn -> Mix.Tasks.Packagr.run(["search", query]) end)
      assert result =~ ~r/^example - \d+.\d+.\d+\n$/
    end
  end

  describe "publish" do
    test "displays response", %{directory_name: directory_name} do
      filepath = directory_name <> "foo.tar.gz"
      expect(Packagr.ApiMock, :publish, fn ^filepath -> :success end)

      File.write(filepath, "some gzipped data")
      result = capture_io(fn -> Mix.Tasks.Packagr.run(["publish", filepath]) end)
      assert result =~ ~r/^success\n$/
    end
  end

  describe "install" do
    test "displays message when package is installed", %{directory_name: directory_name} do
      package_name = "a_package_name"
      version = "0.0.1"
      expect(Packagr.ApiMock, :install, fn ^package_name, ^version ->
        files = [
          {'example/example.js', "console.log(\"this is an example package\");\n"},
          {'example/packagr.yml', "name: #{package_name}\nversion: #{version}\n"}
        ]

        :erl_tar.create(directory_name <> "package.tar.gz", files, [:compressed])

        {:ok, package_gzipped_data} = File.read(directory_name <> "package.tar.gz")
        package_gzipped_data
      end)

      result = capture_io(fn -> Mix.Tasks.Packagr.run(["install", package_name, version]) end)
      assert result =~ ~r/^success\n$/
    end
  end
end
