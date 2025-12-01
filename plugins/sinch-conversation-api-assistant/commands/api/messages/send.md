---
description: Send a message via Sinch Conversation API
allowed-tools:
  - mcp__sinch__send-text-message
  - mcp__sinch__send-media-message
  - mcp__sinch__send-template-message
  - mcp__sinch__send-choice-message
  - mcp__sinch__send-location-message
  - mcp__sinch__sinch-mcp-configuration
argument-hint: --to=<phone> --message=<text> [--channel=<channel>] [--media=<url>] [--template=<id>] [--choices=<option1,option2>] [--location=<address>]
---

# Send Message

Send a message to a recipient using the Sinch Conversation API. Supports text, media, template, choice, and location messages.

## Input

- `--to` / `-t`: Recipient phone number (E.164 format, e.g., +14155551234) - required
- `--message` / `-m`: Text content - required for text and choice messages
- `--channel` / `-c`: Channel (sms, whatsapp, rcs) - optional, defaults to SMS
- `--media`: Media URL for images, videos, or documents - optional
- `--template`: Template ID for predefined templates - optional
- `--choices`: Comma-separated interactive choices/buttons - optional
- `--location`: Address or coordinates to send as location pin - optional

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS:

   - Validate that `--to` is provided and in E.164 format (e.g., +14155551234)
   - If `--channel` is not provided, default to "SMS"
   - Normalize channel to uppercase (sms → SMS, whatsapp → WHATSAPP, rcs → RCS)

2. Determine message type and select the appropriate MCP tool:

   - If `--media` is provided: use `mcp__sinch__send-media-message`
   - If `--template` is provided: use `mcp__sinch__send-template-message`
   - If `--choices` is provided: use `mcp__sinch__send-choice-message`
   - If `--location` is provided: use `mcp__sinch__send-location-message`
   - Otherwise: use `mcp__sinch__send-text-message`

3. Call the selected MCP tool with the appropriate payload constructed from the arguments.

4. Report the result or handle any errors returned by the tool.

## Examples

Send a text message:

```
/sinch-conversation-api-assistant:api:messages:send --to=+14155551234 --message="Hello"
```

Send via WhatsApp:

```
/sinch-conversation-api-assistant:api:messages:send --to=+14155551234 --message="Hello" --channel=whatsapp
```

Send media message:

```
/sinch-conversation-api-assistant:api:messages:send --to=+14155551234 --message="Check this out" --media=https://example.com/image.jpg --channel=whatsapp
```
