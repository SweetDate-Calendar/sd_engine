defmodule CLP.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CLP.Repo,
      {DNSCluster, query: Application.get_env(:clp_engine, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CLP.PubSub}
      # Start a worker by calling: CLP.Worker.start_link(arg)
      # {CLP.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CLP.Supervisor)
  end
end
