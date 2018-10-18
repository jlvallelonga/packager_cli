defmodule PackagrCli do
  @packagr_api Application.get_env(:packagr_cli, :packagr_api)

  @moduledoc """
  Documentation for PackagrCli.
  """

  @doc """
  parses command line arguments and returns them

  this is used from the packagr mix task
  """
  def parse_arguments(argv) do
    get_command_config() |> Optimus.parse!(argv, fn _ -> :noop end)
  end

  def search(%{query: query}) do
    @packagr_api.search(query)
    |> Map.get("packages")
    |> Enum.each(fn package ->
      IO.puts("#{Map.get(package, "name")} - #{Map.get(package, "version")}")
    end)
  end

  def publish(%{filepath: filepath}) do
    response = if File.exists?(filepath) do
      @packagr_api.publish(filepath)
    else
      :error
    end

    IO.puts(to_string(response))
  end

  def install(%{package: package_name, version: version}) do
    package_zipped_data = @packagr_api.install(package_name, version)
    File.mkdir("packages/")
    :erl_tar.extract({:binary, package_zipped_data}, [{:cwd, "packages/"}, :compressed])
    IO.puts("success")
  end

  defp get_command_config() do
    Optimus.new!(
      name: "packagr",
      description: "a very simple package manager",
      version: "0.0.1",
      allow_unknown_args: false,
      parse_double_dash: true,
      subcommands: [
        search: [
          name: "search",
          about: "searches for a package by name",
          args: [
            query: [
              value_name: "QUERY",
              help: "a search term used for finding packages",
              required: true,
              parser: :string
            ]
          ]
        ],
        publish: [
          name: "publish",
          about: "publishes a package (gzipped tarball)",
          args: [
            filepath: [
              value_name: "FILEPATH",
              help: "the path of the gzipped tarball (.tar.gz) containing the package files",
              required: true,
              parser: :string
            ]
          ]
        ],
        install: [
          name: "install",
          about: "installs a package into a /packages directory under the current directory",
          args: [
            package: [
              value_name: "PACKAGE",
              help: "the name of the package to install",
              required: true,
              parser: :string
            ],
            version: [
              value_name: "VERSION",
              help: "the version of the package to install. defaults to latest version",
              required: false,
              parser: :string
            ]
          ]
        ]
      ]
    )
  end
end
