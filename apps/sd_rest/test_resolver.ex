defmodule SD_REST.TestResolver do
  @moduledoc false
  # Swap this out for your real DB-backed resolver later.
  # We'll populate it from the test with a persistent ETS table for simplicity.

  @table :sd_rest_keys

  def start_link do
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    {:ok, self()}
  end

  def put(app_id, pubkey_bin) do
    :ets.insert(@table, {app_id, pubkey_bin})
    :ok
  end

  def pubkey(app_id) do
    case :ets.lookup(@table, app_id) do
      [{^app_id, pk}] -> {:ok, pk}
      _ -> :error
    end
  end
end
