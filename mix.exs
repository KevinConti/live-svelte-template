defmodule UxExpress.MixProject do
  use Mix.Project

  @doc """
  Project configuration for UxExpress.
  
  Note on build system:
  We've moved from Phoenix's default esbuild setup to a custom Node-based build system
  to support LiveSvelte integration. This change was necessary because:
  1. Phoenix's default esbuild configuration doesn't support plugins
  2. LiveSvelte requires esbuild plugins for proper functionality
  3. The build process is now handled by Node.js scripts in the /assets directory

  LiveSvelte Integration:
  LiveSvelte bridges Phoenix LiveView and Svelte by:
  1. Providing a <.svelte> component for LiveView templates
  2. Managing server-side rendering (SSR) of Svelte components
  3. Handling client-side hydration for interactivity
  4. Coordinating real-time updates between LiveView and Svelte

  The integration requires:
  - nodejs dependency for server-side rendering
  - Custom build configuration in /assets
  - Specific component export structure in server.js
  """
  def project do
    [
      app: :ux_express,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      mod: {UxExpress.Application, []},
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
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # TODO bump on release to {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:live_svelte, "~> 0.14.0"},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd --cd assets npm install"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "tailwind ux_express"],
      "assets.build": ["tailwind ux_express", "cmd --cd assets node build.js"],
      "assets.deploy": ["tailwind ux_express --minify", "cmd --cd assets node build.js --deploy", "phx.digest"]
    ]
  end
end
