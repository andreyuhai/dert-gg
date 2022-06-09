defmodule DertGGWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :dert_gg_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DertGGWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:argon2_elixir, "~> 2.4"},
      {:corsica, "~> 1.1"},
      {:dert_gg, in_umbrella: true},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 2.2"},
      {:hackney, "~> 1.18"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.6"},
      {:phoenix_active_link, "~> 0.3.2"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.1"},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:phoenix_swoosh, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:sentry, "~> 8.0"},
      {:swoosh, "~> 1.6"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:tzdata, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
