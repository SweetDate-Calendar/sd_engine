defmodule SD.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SD.Repo,
      {DNSCluster, query: Application.get_env(:sd_engine, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SD.PubSub}
      # Start a worker by calling: SD.Worker.start_link(arg)
      # {SD.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SD.Supervisor)
  end
end
