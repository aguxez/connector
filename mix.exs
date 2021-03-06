defmodule Connector.MixProject do
  use Mix.Project

  def project do
    [
      app: :connector,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Connector.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:websocket_client, "~> 1.3"},
      {:websockex, github: "Azolo/websockex"},
      {:tesla, "~> 0.10.0"},
      {:jason, "~> 1.0.0"},
      {:pastry, "~> 0.3.0"},
      {:credo, "~> 0.9.3", only: [:dev, :test]}
    ]
  end
end
