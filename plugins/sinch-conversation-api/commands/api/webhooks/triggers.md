---
description: List available webhook triggers (message-related only)
allowed-tools:
  - mcp__sinch__sinch-mcp-configuration
argument-hint: [--format=json|table]
---

# Webhook Triggers (Message-Related)

List all available message-related webhook triggers for the Sinch Conversation API.

## Input

- `--format` / `-f`: Output format (json or table) - optional, defaults to table

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS:

   - If `--format` is not provided, default to "table"
   - Validate that format is either "json" or "table"
   - Normalize format to lowercase

2. Display the message-related webhook triggers based on the requested format.

3. For **table format**, display a formatted table with columns:

   - **Trigger**: The trigger name (uppercase)
   - **Label**: Human-readable name
   - **Description**: Brief description of when the trigger fires

4. For **json format**, display the triggers as a JSON array with objects containing:
   - `trigger`: The trigger name
   - `label`: Human-readable name
   - `description`: Detailed description
   - `category`: "message"

## Message-Related Triggers

The following triggers are related to message operations:

### MESSAGE_INBOUND

- **Label**: Message Inbound
- **Description**: Subscribe to inbound messages from end users on the underlying channels. This trigger fires when a contact sends a message to your app.
- **Use Case**: Receiving and processing incoming messages from customers

### MESSAGE_DELIVERY

- **Label**: Message Delivery
- **Description**: Subscribe to delivery receipts for messages sent. This trigger fires when a message delivery status changes (e.g., sent, delivered, failed).
- **Use Case**: Tracking message delivery status and handling delivery failures

### MESSAGE_SUBMIT

- **Label**: Message Submit
- **Description**: Subscribe to message submission events. This trigger fires when a message is submitted for delivery to the channel.
- **Use Case**: Tracking when messages are submitted to the underlying channel

### MESSAGE_INBOUND_SMART_CONVERSATION_REDACTION

- **Label**: Message Inbound Smart Conversation Redaction
- **Description**: Subscribe to smart conversation redaction events for inbound messages. This trigger fires when sensitive data is detected and redacted from inbound messages.
- **Use Case**: Monitoring data privacy and PII redaction in conversations

## Examples

List message triggers in table format:

```
/sinch-conversation-api:api:webhooks:triggers
```

List message triggers in JSON format:

```
/sinch-conversation-api:api:webhooks:triggers --format=json
```

## Table Format Output Example

```
Message-Related Webhook Triggers
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Trigger                                         Label                                      Description
─────────────────────────────────────────────────────────────────────────────────────────────────────────
MESSAGE_INBOUND                                 Message Inbound                            Inbound messages from end users
MESSAGE_DELIVERY                                Message Delivery                           Delivery receipts for sent messages
MESSAGE_SUBMIT                                  Message Submit                             Message submission events
MESSAGE_INBOUND_SMART_CONVERSATION_REDACTION    Smart Conversation Redaction               Smart conversation redaction events
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## JSON Format Output Example

```json
{
  "triggers": [
    {
      "trigger": "MESSAGE_INBOUND",
      "label": "Message Inbound",
      "description": "Subscribe to inbound messages from end users on the underlying channels. Fires when a contact sends a message to your app.",
      "category": "message",
      "payload_example": {
        "message": {
          "id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z",
          "direction": "TO_APP",
          "contact_message": {
            "text_message": {
              "text": "Hello from customer"
            }
          }
        },
        "conversation_id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z",
        "contact_id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z",
        "channel_identity": {
          "channel": "SMS",
          "identity": "+14155551234",
          "app_id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z"
        }
      }
    },
    {
      "trigger": "MESSAGE_DELIVERY",
      "label": "Message Delivery",
      "description": "Subscribe to delivery receipts for messages sent. Fires when message delivery status changes.",
      "category": "message",
      "payload_example": {
        "message_id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z",
        "conversation_id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z",
        "channel_identity": {
          "channel": "SMS",
          "identity": "+14155551234",
          "app_id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z"
        },
        "contact_id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z",
        "delivery_report": {
          "status": "DELIVERED",
          "code": 0,
          "comment": "Message delivered successfully",
          "timestamp": "2023-10-15T14:30:00Z"
        }
      }
    },
    {
      "trigger": "MESSAGE_SUBMIT",
      "label": "Message Submit",
      "description": "Subscribe to message submission events. Fires when a message is submitted for delivery.",
      "category": "message"
    },
    {
      "trigger": "MESSAGE_INBOUND_SMART_CONVERSATION_REDACTION",
      "label": "Smart Conversation Redaction",
      "description": "Subscribe to smart conversation redaction events for inbound messages. Fires when sensitive data is detected and redacted.",
      "category": "message"
    }
  ]
}
```

## Usage in Webhook Commands

These triggers can be used with the webhook create and update commands:

```
# Create webhook with message triggers
/sinch-conversation-api:api:webhooks:create --target=https://example.com/webhook --triggers=MESSAGE_INBOUND,MESSAGE_DELIVERY

# Update webhook to include message submit trigger
/sinch-conversation-api:api:webhooks:update --id=01E9... --triggers=MESSAGE_INBOUND,MESSAGE_DELIVERY,MESSAGE_SUBMIT
```

## API Reference

- **Webhooks Documentation**: https://developers.sinch.com/docs/conversation/webhooks/
- **Webhook Triggers**: https://developers.sinch.com/docs/conversation/api-reference/conversation/tag/Webhooks/#tag/Webhooks/operation/Webhooks_CreateWebhook

## Notes

- This command shows only message-related triggers
- Other webhook triggers exist for events, contacts, conversations, etc. (not shown here per requirements)
- You can subscribe to multiple triggers in a single webhook
- Each trigger type has a specific payload structure
- All triggers require a valid HTTPS webhook endpoint
