ExUnit.start(timeout: 100)
Ecto.Adapters.SQL.Sandbox.mode(CLP.Repo, :manual)

Path.wildcard(Path.expand("support/**/*.exs", __DIR__))
|> Enum.each(&Code.require_file/1)

defmodule ClpTcp.TestHelper do
  @moduledoc false

  def tcp_send(message) do
    port = System.get_env("TCP_PORT") |> String.to_integer()
    {:ok, socket} = :gen_tcp.connect(~c"localhost", port, [:binary, active: false])
    :ok = :gen_tcp.send(socket, message <> "\n")
    {:ok, response} = :gen_tcp.recv(socket, 0)
    :gen_tcp.close(socket)
    Jason.decode!(response)
  end
end
