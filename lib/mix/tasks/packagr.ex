defmodule Mix.Tasks.Packagr do
  use Mix.Task

  @shortdoc "a very simple package manager"
  @moduledoc ~S"""
    see help with `mix packagr --help`
  """

  def run(argv) do
    case PackagrCli.parse_arguments(argv) do
      {[subcommand], %Optimus.ParseResult{args: args}} ->
        apply(PackagrCli, subcommand, [args])

      _ ->
        :ok
    end
  end
end
