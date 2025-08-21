defmodule SDRest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SDRest.Telemetry,
      # Start a worker by calling: SDRest.Worker.start_link(arg)
      # {SDRest.Worker, arg},
      # Start to serve requests, typically the last entry
      SDRest.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SDRest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SDRest.Endpoint.config_change(changed, removed)
    :ok
  end
end
