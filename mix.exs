defmodule Attercop.MixProject do
  use Mix.Project

  def project do
    [
      app: :attercop,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Attercop.CLI],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cli_spinners, "~> 0.1.0"},
      {:ex_cli, "~> 0.1.0"},
      {:httpoison, "~> 1.6.2"},
      {:jason, "~> 1.1"},
      {:jose, "~>1.10"},
      {:neuron, "~> 5.0.0"},
      {:mox, "~> 0.5.2"},
      {:sweet_xml, "~> 0.6"},
      {:table_rex, "~> 3.0.0"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
    ]
  end
end
