defmodule ClpTcp.Handlers.Ping do
  def dispatch(_), do: %{status: "ok", message: "pong"}
end
