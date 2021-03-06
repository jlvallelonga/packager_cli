defmodule Mix.Tasks.Packagr do
  use Mix.Task

  @shortdoc "a very simple package manager"
  @moduledoc ~S"""
    see help with `mix packagr --help`
  """

  def run(argv) do
    case Packagr.parse_arguments(argv) do
      {[subcommand], %Optimus.ParseResult{args: args}} ->
        apply(Packagr, subcommand, [args])

      _ ->
        :ok
    end
  end
end
