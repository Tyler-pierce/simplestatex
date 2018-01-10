defmodule SimpleStatEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :simplestatex,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
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
      {:phoenix_ecto, "~> 3.0"},
      {:timex, "~> 3.1.15", override: true},
      {:timex_ecto, "~> 3.1.1", override: true}
    ]
  end
end
