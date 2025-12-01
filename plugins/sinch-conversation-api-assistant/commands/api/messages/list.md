---
description: List messages from Sinch Conversation API
allowed-tools: mcp__sinch__list_messages
argument-hint: --page_size=<number> --contact_id=<id>
---

# List Messages

List messages from the Sinch Conversation API history.

## Input

- `--page_size` / `-p`: Number of messages to retrieve (optional)
- `--contact_id`: Filter by contact ID (optional)
- `--app_id`: Filter by App ID (optional)

$ARGUMENTS

## Instructions

1. Parse arguments from $ARGUMENTS.
2. Call the MCP tool `mcp__sinch__list_messages` with the appropriate parameters.
3. Display the list of messages in a readable format.
