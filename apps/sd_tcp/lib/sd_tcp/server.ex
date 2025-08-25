defmodule SDTCP.Server do
  @moduledoc "TCP server"

  require Logger
  @sweet_date_api_key_id Application.compile_env(:sd_engine, :tcp)[:sweet_date_api_key_id]
  @sweet_date_api_secret Application.compile_env(:sd_engine, :tcp)[:sweet_date_api_secret]

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
            [cmd_only] -> [String.trim(cmd_only), "{}"]
          end

        case Jason.decode(json) do
          {:ok, payload} ->
            if authorized?(payload) do
              response = dispatch(command, payload)
              :gen_tcp.send(socket, Jason.encode!(response) <> "\n")
            else
              :gen_tcp.send(
                socket,
                Jason.encode!(%{status: "error", message: "unauthorized"}) <> "\n"
              )
            end

          {:error, _} ->
            :gen_tcp.send(
              socket,
              Jason.encode!(%{status: "error", message: "invalid json"}) <> "\n"
            )
        end

        handle(socket)

      {:error, _} ->
        :gen_tcp.close(socket)
    end
  end

  defp authorized?(%{
         "sweet_date_api_key_id" => sweet_date_api_key_id,
         "sweet_date_api_secret" => sweet_date_api_secret
       }) do
    @sweet_date_api_key_id == sweet_date_api_key_id &&
      @sweet_date_api_secret == sweet_date_api_secret
  end

  defp authorized?(_) do
    false
  end

  # defp authorized?(_), do: false

  defp dispatch("PING", json), do: SDTCP.Handlers.Ping.dispatch(json)
  defp dispatch("TENANTS." <> action, json), do: SDTCP.Handlers.Tenants.dispatch(action, json)

  defp dispatch("CALENDARS." <> action, json),
    do: SDTCP.Handlers.SweetDate.dispatch(action, json)

  # defp dispatch("CALENDARS." <> action, json),
  #   do: SDTCP.Handlers.SweetDate.dispatch(action, json)

  defp dispatch(_, _), do: %{status: "error", message: "unknown command"}
end
