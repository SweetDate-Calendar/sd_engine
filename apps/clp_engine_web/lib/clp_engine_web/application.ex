defmodule CLPWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CLPWeb.Telemetry,
      # Start a worker by calling: CLPWeb.Worker.start_link(arg)
      # {CLPWeb.Worker, arg},
      # Start to serve requests, typically the last entry
      CLPWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CLPWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CLPWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
