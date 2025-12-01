---
description: Get delivery status and events for a message
allowed-tools:
  - mcp__sinch__get-message-events
  - mcp__sinch__sinch-mcp-configuration
argument-hint: --message_id=<id>
---

# Get Message Status

Retrieve delivery status and events for a specific message sent via Sinch Conversation API.

## Input

- `--message_id` / `-m`: Message ID to retrieve events for (required)

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS.
   - Validate that `--message_id` is provided and non-empty
2. Call the MCP tool `mcp__sinch__get-message-events` with the message ID.

3. Display the events in a table format if possible, showing:

   - Event type (e.g., DELIVERED, READ, FAILED)
   - Timestamp
   - Status details

   If table format is not suitable, fallback to a list format with clear labels for each event.

4. Report any errors returned by the tool.

## Example

```
/sinch-conversation-api-assistant:api:messages:status --message_id=01HXXX123456
```
