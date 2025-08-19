# SD_REST


SD_REST is the REST API 

## Part of the `sd_engine` Umbrella

This app is located under the `apps/sd_rest/` directory inside the `sd_engine` umbrella project.

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
