ExUnit.start(timeout: 100)
Ecto.Adapters.SQL.Sandbox.mode(SD.Repo, :manual)

Path.wildcard(Path.expand("support/**/*.exs", __DIR__))
|> Enum.each(&Code.require_file/1)

defmodule SDTCP.TestHelper do
  @moduledoc false
  @sweet_date_account_id Application.compile_env(:sd_engine, :tcp)[:sweet_date_account_id]
  @sweet_access_api_key Application.compile_env(:sd_engine, :tcp)[:sweet_access_api_key]

  def sd_send(message) do
    port = System.get_env("TCP_PORT") |> String.to_integer()
    {:ok, socket} = :gen_tcp.connect(~c"localhost", port, [:binary, active: false])
    :ok = :gen_tcp.send(socket, message <> "\n")
    {:ok, response} = :gen_tcp.recv(socket, 0)
    :gen_tcp.close(socket)
    Jason.decode!(response)
  end

  def authorize(data) when is_map(data) do
    Map.merge(data, %{
      "sweet_date_account_id" => @sweet_date_account_id,
      "access_key" => @sweet_access_api_key
    })
  end
end
