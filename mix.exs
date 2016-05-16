defmodule Netstrings.Mixfile do
  use Mix.Project

  def project do
    [app: :netstrings,
     version: "2.0.1",
     elixir: "~> 1.2",
     name: "Netstrings",
     source_url: "https://github.com/mwmiller/netstrings_ex",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps,
     docs: [extras: ["README.md"]]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:earmark, "~> 0.2", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:power_assert, "~> 0.0.8", only: :test},
      {:temp, "~> 0.3.0", only: :test},
    ]
  end
  defp description do
    """
    Netstrings implementaton
    """
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README*", "LICENSE*", ],
     maintainers: ["Matt Miller"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mwmiller/netstrings_ex",}
    ]
  end

end
