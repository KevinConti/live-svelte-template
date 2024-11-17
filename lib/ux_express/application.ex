defmodule UxExpress.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {NodeJS.Supervisor, [
        path: LiveSvelte.SSR.NodeJS.server_path(),
        pool_size: 4,
        node_path: Application.get_env(:nodejs, :node_path)
      ]},
      UxExpressWeb.Telemetry,
      UxExpress.Repo,
      {DNSCluster, query: Application.get_env(:ux_express, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UxExpress.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: UxExpress.Finch},
      # Start a worker by calling: UxExpress.Worker.start_link(arg)
      # {UxExpress.Worker, arg},
      # Start to serve requests, typically the last entry
      UxExpressWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UxExpress.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UxExpressWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
