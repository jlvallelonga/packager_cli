defmodule PackagrCli do
  @moduledoc """
  Documentation for PackagrCli.
  """

  @doc """
  Hello world.

  ## Examples

      iex> PackagrCli.hello()
      :world

  """
  def hello do
    :world
  end

  def main(argv) do
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
    ) |> Optimus.parse!(argv)
  end
end
