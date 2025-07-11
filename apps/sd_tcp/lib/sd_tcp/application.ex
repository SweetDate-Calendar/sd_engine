defmodule SDTCP.Application do
  use Application

  def start(_type, _args) do
    port = Application.get_env(:SD, :tcp)[:port] || 5050

    children = [
      {SDTCP.Server, port}
    ]

    opts = [strategy: :one_for_one, name: SDTCP.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
