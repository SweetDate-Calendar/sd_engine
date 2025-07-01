defmodule ClpTcp.Application do
  use Application

  def start(_type, _args) do
    children = [
      {ClpTcp.Server, String.to_integer(System.get_env("TCP_PORT") || "5050")}
    ]

    opts = [strategy: :one_for_one, name: ClpTcp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
