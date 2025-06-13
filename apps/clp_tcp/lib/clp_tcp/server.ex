defmodule ClpTcp.Server do
  @moduledoc "TCP server"

  require Logger

  # 👇 This makes the module supervisor-compatible
  def child_spec(port) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [port]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(port \\ 5050) do
    Task.start_link(fn -> listen(port) end)
  end

  defp listen(port) do
    case :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        Logger.info("TCP server listening on port #{port}")
        accept(socket)

      {:error, reason} ->
        Logger.error("Failed to start TCP server: #{inspect(reason)}")
    end
  end

  defp accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    spawn(fn -> handle(client) end)
    accept(socket)
  end

  defp handle(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, raw} ->
        [command, json] =
          case String.split(raw, "|", parts: 2) do
            [cmd, body] -> [String.trim(cmd), String.trim(body)]
            # handles "PING\n"
            [cmd_only] -> [String.trim(cmd_only), "{}"]
          end

        response = dispatch(command, json)
        :gen_tcp.send(socket, Jason.encode!(response) <> "\n")
        handle(socket)

      {:error, _} ->
        :gen_tcp.close(socket)
    end
  end

  defp dispatch("PING", json), do: ClpTcp.Handlers.Ping.dispatch(json)
  # defp dispatch("AUTH." <> action, json), do: ClpTcp.Handlers.Auth.dispatch(action, json)

  # defp dispatch("CALENDARS." <> action, json),
  #   do: ClpTcp.Handlers.Calendars.dispatch(action, json)

  defp dispatch(_, _), do: %{status: "error", message: "unknown command"}
end
