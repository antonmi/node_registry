defmodule NodeRegistry.MixProject do
  use Mix.Project

  def project do
    [
      app: :node_registry,
      version: "0.1.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      source_url: "https://github.com/antonmi/node_registry",
      deps: deps()
    ]
  end

  defp description do
    "A simple node registry built on top of the Erlang's :global module"
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md),
      maintainers: ["Anton Mishchuk"],
      licenses: ["MIT"],
      links: %{"github" => "https://github.com/antonmi/node_registry"}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end
end
