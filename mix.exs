defmodule ZohomailApi.Mixfile do
  use Mix.Project

  def project do
    [app: :zohomail_api,
     version: "0.0.2",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Send emails using ZohoMail's REST API",
     package: package(),
     deps: deps()]
  end

  defp package do
    [maintainers: ["duzzifelipe"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/duzzifelipe/zohomail_api"}]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:poison, "~> 3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
