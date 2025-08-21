defmodule SDRest.MixProject do
  use Mix.Project

  def project do
    [
      app: :sd_rest,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
      # removed: listeners: [Phoenix.CodeReloader]
    ]
  end

  def application do
    [
      mod: {SDRest.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.8.0-rc.3", override: true},
      {:phoenix_ecto, "~> 4.5"},
      # floki is only for HTML/LiveView testing; safe to remove for API-only.
      # {:floki, ">= 0.30.0", only: :test},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:sd_engine, in_umbrella: true},
      {:jason, "~> 1.4.4"},
      {:bandit, "~> 1.7"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
      # removed: assets.setup, assets.build, assets.deploy
    ]
  end
end
