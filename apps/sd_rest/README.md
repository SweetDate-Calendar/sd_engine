# SD_REST



## Part of the `sd_engine` Umbrella

This app is located under the `apps/sd_rest/` directory inside the `sd_engine` umbrella project.

## Running


BASE_URL="https://your-host.tld"  
APP_ID="your-app-id"               
SECRET_B64URL="your-ed25519-secret-base64url"

# Generate headers
read H1 H2 H3 < <(node sign.js GET /whoami "$APP_ID" "$SECRET_B64URL" | paste -sd' ' -)

# Call endpoint
curl -i \
  -H "${H1}" \
  -H "${H2}" \
  -H "${H3}" \
  "$BASE_URL/whoami"