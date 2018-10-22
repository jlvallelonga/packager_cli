defmodule Packagr.MixProject do
  use Mix.Project

  def project do
    [
      app: :packagr,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:optimus, "~> 0.1.0"},
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:mox, "~> 0.4", only: :test},
      {:faker, "~> 0.11", only: [:dev, :test]}
    ]
  end
end
