defmodule Bookstore.MixProject do
  use Mix.Project

  def project do
    [
      app: :bookstore,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BookStore.App, []},
      env: [
        pg: [
          database: 'bookstore',
          host: '127.0.0.1',
          port: 5432,
          ssl: false
        ]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:eql, "~> 0.1.2", manager: :rebar3},
      {:pgsql, "~> 26.0", manager: :rebar3},
      {:propcheck, "~> 1.1", only: [:test, :dev]},
    ]
  end
end
