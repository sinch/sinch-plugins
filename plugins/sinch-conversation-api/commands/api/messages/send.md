---
description: Send a text message via Sinch Conversation API (SMS/RCS only)
allowed-tools:
  - mcp__sinch__send-text-message
  - mcp__sinch__sinch-mcp-configuration
argument-hint: --to=<phone> --message=<text> [--channel=SMS|RCS]
---

# Send Message

Send a text message to a recipient using the Sinch Conversation API. Currently supports SMS channels only.

## Input

- `--to` / `-t`: Recipient phone number (E.164 format, e.g., +14155551234) - required
- `--message` / `-m`: Text content - required
- `--channel` / `-c`: Channel (SMS or RCS) - optional, defaults to SMS

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
   - If missing, report: "MCP tool `mcp__sinch__send-text-message` is not available. Please check your MCP server configuration and ensure the Sinch Conversation API MCP server is properly configured with required environment variables."
   - If available but still failed, report the original error

## Examples

Send an SMS message:

```
/sinch-conversation-api:api:messages:send --to=+14155551234 --message="Hello"
```

Send an RCS message:

```
/sinch-conversation-api:api:messages:send --to=+14155551234 --message="Hello" --channel=RCS
```
