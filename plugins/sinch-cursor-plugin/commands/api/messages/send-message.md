---
name: messages-send
description: Send a message via Sinch Conversation API (SMS, RCS)
allowed-tools:
  - mcp__sinch__send-text-message
  - mcp__sinch__send-media-message
  - mcp__sinch__send-location-message
  - mcp__sinch__send-choice-message
  - mcp__sinch__send-template-message
  - mcp__sinch__sinch-mcp-configuration
argument-hint: --to=<phone> --message=<text> [--channel=SMS|RCS] [--type=text|media|location|choice|template]
---

# Send Message

Send a message to a recipient using the Sinch Conversation API. Supports SMS and RCS channels.

## Input

- `--to` / `-t`: Recipient phone number (E.164 format, e.g., +14155551234) - required
- `--message` / `-m`: Text content - required for text messages
- `--channel` / `-c`: Channel (SMS, RCS) - optional, defaults to SMS
- `--type`: Message type (text, media, location, choice, template) - optional, defaults to text
- `--url`: Media URL for media messages - required when type=media
- `--template-id`: Template ID for template messages - required when type=template
- `--fallback`: Comma-separated channel fallback order (e.g., RCS,SMS) - optional

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS:

   - Validate that `--to` is provided and in E.164 format (e.g., +14155551234)
   - Validate that `--message` is provided and non-empty (for text messages)
   - If `--channel` is not provided, default to "SMS"
   - Normalize channel to uppercase (sms → SMS, rcs → RCS)
   - Validate channel is one of: SMS, RCS
   - If `--type` is not provided, default to "text"
   - Normalize type to lowercase

2. Select the appropriate MCP tool based on `--type`:

   - `text` → `mcp__sinch__send-text-message`
   - `media` → `mcp__sinch__send-media-message` (requires `--url`)
   - `location` → `mcp__sinch__send-location-message` (requires address)
   - `choice` → `mcp__sinch__send-choice-message` (requires choice content)
   - `template` → `mcp__sinch__send-template-message` (requires `--template-id`)

3. If `--fallback` is provided, pass it as `channel_priority_order` to attempt channels in order with automatic fallback.

4. Call the selected MCP tool with the recipient, message content, and channel.

5. Report the result or handle any errors returned by the tool.

6. If the tool call fails with an error, call `mcp__sinch__sinch-mcp-configuration` to verify MCP server availability:

   - Check if the MCP tool is in the list of available/enabled tools
   - If missing, report: "MCP tool is not available. Run `/sinch-claude-plugin:sinch-mcp-setup` to see setup instructions."

7. Fallback (if MCP is unavailable OR the MCP tool keeps failing): build a direct Conversation API `curl` request.

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
        "app_id": "${CONVERSATION_APP_ID}",
        "recipient": {
           "identified_by": {
              "channel_identities": [
                 {
                    "channel": "${CHANNEL}",
                    "identity": "${TO}"
                 }
              ]
           }
        },
        "message": {
           "text_message": {
              "text": "${MESSAGE}"
           }
        },
        "channel_properties": {
           "SMS_SENDER": "+15559876543"
        }
     }
     JSON
     )"
     ```

   - For channel fallback, add `channel_priority_order` to the request body:
     ```json
     "channel_priority_order": ["RCS", "SMS"]
     ```

   - If the direct API call still fails, show the HTTP status + response body, and suggest verifying:
     - Channel is enabled in the Conversation app for the given `CONVERSATION_APP_ID`
     - `CONVERSATION_REGION` matches where the project is provisioned (e.g., `us`, `eu`, `br`)
     - The key has permission to send messages
     - `channel_properties` are set correctly (e.g., `SMS_SENDER` for SMS)

## Examples

Send an SMS message:

```
/sinch-claude-plugin:api:messages:send --to=+14155551234 --message="Hello"
```

Send an RCS message:

```
/sinch-claude-plugin:api:messages:send --to=+14155551234 --message="Hello" --channel=RCS
```

Send a media message via RCS:

```
/sinch-claude-plugin:api:messages:send --to=+14155551234 --type=media --url=https://example.com/image.jpg --channel=RCS
```

Send with channel fallback (try RCS first, then SMS):

```
/sinch-claude-plugin:api:messages:send --to=+14155551234 --message="Hello" --fallback=RCS,SMS
```