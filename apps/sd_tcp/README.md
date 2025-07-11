# ClpTcp


ClpTcp is a lightweight TCP server for handling protocol-based communication in the SD engine. It listens for incoming connections and dispatches namespaced commands (e.g., `PING`, `CALENDARS.CREATE`) using a simple, JSON-encoded message format.

## Part of the `sd_engine` Umbrella

This app is located under the `apps/sd_tcp/` directory inside the `sd_engine` umbrella project.

## Running

Start the TCP server by running the umbrella app:

```bash
cd sd_engine
mix deps.get
iex -S mix
```

## Confirm from terminal
```bash
echo "PING" | nc localhost 5050
```
