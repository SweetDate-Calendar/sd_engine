defmodule SD_REST.Application do
  use Application

  def start(_type, _args) do
    IO.inspect("SD_REST.Application started successfully")

    children = []

    opts = [strategy: :one_for_one, name: SD_REST.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
