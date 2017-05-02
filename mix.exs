defmodule TgCwibot.Mixfile do
  use Mix.Project

  def project do
    [app: :tg_cwibot,
     version: "0.1.3",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [:logger, :edeliver, :runtime_tools],
      mod: {TgCwibot, []}
    ]
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
      {:edeliver, "~> 1.4"},
      {:distillery, "~> 1.2"},
      {:tesla, "~> 0.6.0"},
      {:cowboy, "~> 1.1"},
      {:hackney, "~> 1.6"},
      {:plug, "~> 1.3"},
      {:poison, "~> 3.1"}
    ]
  end
end
