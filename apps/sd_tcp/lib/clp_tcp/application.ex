defmodule ClpTcp.Application do
  use Application

  def start(_type, _args) do
    port = Application.get_env(:SD, :tcp)[:port] || 5050

    children = [
      {ClpTcp.Server, port}
    ]

    opts = [strategy: :one_for_one, name: ClpTcp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
