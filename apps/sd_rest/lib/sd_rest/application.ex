# defmodule SD_REST.Application do
#   use Application

#   def start(_type, _args) do
#     IO.inspect("SD_REST.Application started successfully")

#     children = []

#     opts = [strategy: :one_for_one, name: SD_REST.Supervisor]
#     Supervisor.start_link(children, opts)
#   end
# end


defmodule SD_REST.Application do
  use Application
  require Logger

  def start(_type, _args) do
    port = Application.get_env(:sd_rest, :api, [])[:port] || 4003
    Logger.info("SD_REST listening on port #{port}")

    children = [
      {
        Bandit,
        plug: SD_REST.Router,
        scheme: :http,
        port: port
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SD_REST.Supervisor)
  end
end
