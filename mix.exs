defmodule Netstrings.Mixfile do
  use Mix.Project

  def project do
    [app: :netstrings,
     version: "2.0.5",
     elixir: "~> 1.4",
     name: "Netstrings",
     source_url: "https://github.com/mwmiller/netstrings_ex",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     docs: [extras: ["README.md"]]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev},
      {:temp, "~> 0.4", only: :test},
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
