---
description: Send a message via Sinch Conversation API
allowed-tools: mcp__sinch__send_message
argument-hint: --channel=<channel> --to=<phone> --message=<text>
---

# Send Message

Send a message to a recipient using the Sinch Conversation API.

## Input

- `--channel` / `-c`: Channel (sms, whatsapp, rcs)
- `--to` / `-t`: Recipient (E.164 format)
- `--message` / `-m`: Content text

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS.
2. Call the MCP tool `mcp__sinch__send_message` with the payload constructed from the arguments.
   Example payload structure:
   ```json
   {
     "channel": "SMS",
     "recipient": "+14155551234",
     "message": { "text": "Hello" }
   }
   ```
3. Report the result or handle any errors returned by the tool.
