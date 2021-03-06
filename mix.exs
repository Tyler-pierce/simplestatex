defmodule SimpleStatEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :simplestatex,
      version: "0.3.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
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
      {:ecto, "~> 3.1"},
      {:timex, "~> 3.6"},

      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A Statistic Counter designed for simplicity and ease of use. Stats are rolled into time periods of your choice."
  end

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Tyler Pierce"],
      files: ["lib", "mix.exs", "README.md", "test", "config", "priv"],
      links: %{"GitHub" => "https://github.com/Tyler-pierce/simplestatex"},
      source_url: "https://github.com/Tyler-pierce/simplestatex"
    ]
  end
end
