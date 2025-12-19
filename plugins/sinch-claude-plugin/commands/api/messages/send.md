---
description: Send a text message via Sinch Conversation API (SMS/RCS only)
allowed-tools:
  - mcp__sinch__send-text-message
  - mcp__sinch__sinch-mcp-configuration
argument-hint: --to=<phone> --message=<text> [--channel=SMS|RCS]
---

# Send Message

Send a text message to a recipient using the Sinch Conversation API. Currently supports SMS only (RCS comming soon).

## Input

- `--to` / `-t`: Recipient phone number (E.164 format, e.g., +14155551234) - required
- `--message` / `-m`: Text content - required
- `--channel` / `-c`: Channel (SMS) - optional, defaults to SMS

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS:

   - Validate that `--to` is provided and in E.164 format (e.g., +14155551234)
   - Validate that `--message` is provided and non-empty
   - If `--channel` is not provided, default to "SMS"
   - Normalize channel to uppercase (sms → SMS, rcs → RCS)
   - Validate that channel is either "SMS" or "RCS" (reject other channels)

2. Call `mcp__sinch__send-text-message` with the recipient, message, and channel.

3. Report the result or handle any errors returned by the tool.

4. If the tool call fails with an error, call `mcp__sinch__sinch-mcp-configuration` to verify MCP server availability:

   - Check if `mcp__sinch__send-text-message` is in the list of available/enabled tools
   - If missing, report: "MCP tool `mcp__sinch__send-text-message` is not available. Run `/sinch-claude-plugin:sinch-mcp-setup` to see setup instructions."

5. Fallback (if MCP is unavailable OR the MCP tool keeps failing): build a direct Conversation API `curl` request.

   - Retrieve configuration from environment variables:
     - `CONVERSATION_PROJECT_ID`
     - `CONVERSATION_REGION`
     - `CONVERSATION_APP_ID`
     - `CONVERSATION_KEY_ID`
     - `CONVERSATION_KEY_SECRET`
   - If any are missing, report: "Sinch API is not configured. Please set: CONVERSATION_PROJECT_ID, CONVERSATION_KEY_ID, CONVERSATION_KEY_SECRET, CONVERSATION_REGION, CONVERSATION_APP_ID"

   - Then output a ready-to-run command (do not write scripts/files):

     ```bash
     CHANNEL="<SMS>" \
     TO="<+14155551234>" \
     MESSAGE="<Hello>" \
     curl -sS -X POST \
        "https://${CONVERSATION_REGION}.conversation.api.sinch.com/v1/projects/${CONVERSATION_PROJECT_ID}/messages:send" \
        -u "${CONVERSATION_KEY_ID}:${CONVERSATION_KEY_SECRET}" \
        -H "Content-Type: application/json" \
        -d "$(cat <<'JSON'
     {
        \"app_id\": \"${CONVERSATION_APP_ID}\",
        \"recipient\": {
           \"identified_by\": {
              \"channel_identities\": [
                 {
                    \"channel\": \"${CHANNEL}\",
                    \"identity\": \"${TO}\"
                 }
              ]
           }
        },
        \"message\": {
           \"text_message\": {
              \"text\": \"${MESSAGE}\"
           }
        }
     }
     JSON
     )"
     ```

   - If the direct API call still fails, show the HTTP status + response body, and suggest verifying:
     - Channel is enabled in the Conversation app for the given `CONVERSATION_APP_ID`
     - `CONVERSATION_REGION` matches where the project is provisioned (e.g., `us`, `eu`, `br`)
     - The key has permission to send messages

## Examples

Send an SMS message:

```
/sinch-claude-plugin:api:messages:send --to=+14155551234 --message="Hello"
```
