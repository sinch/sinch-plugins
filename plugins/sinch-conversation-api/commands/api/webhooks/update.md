---
description: Update an existing webhook configuration
allowed-tools:
  - mcp__sinch__sinch-mcp-configuration
argument-hint: --id=<webhook-id> [--target=<url>] [--triggers=<trigger1,trigger2,...>] [--secret=<secret>]
---

# Update Webhook

Update an existing webhook's configuration including target URL, triggers, or secret.

## Input

- `--id`: Webhook ID to update - required
- `--target` / `-t`: New webhook target URL (must be HTTPS) - optional
- `--triggers` / `-tr`: New comma-separated list of webhook triggers - optional
- `--secret` / `-s`: New secret for webhook signature verification - optional

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS:

   - Validate that `--id` is provided and non-empty
   - If `--target` is provided, validate it's a valid HTTPS URL (must start with https://)
   - If `--triggers` is provided:
     - Parse triggers into an array by splitting on commas and trimming whitespace
     - Normalize each trigger to uppercase (e.g., message_inbound → MESSAGE_INBOUND)
     - Validate that all triggers are valid webhook trigger values
   - If `--secret` is provided, ensure it's at least 16 characters long
   - Ensure at least one of `--target`, `--triggers`, or `--secret` is provided for the update

2. Call `mcp__sinch__sinch-mcp-configuration` to get the current configuration.

3. Verify the webhook exists:

   - List existing webhooks to verify the webhook ID exists
   - If the webhook doesn't exist, report error: "Webhook with ID '{webhook_id}' not found"

4. Update the webhook using the Sinch Conversation API:

   - Endpoint: `PATCH https://{region}.conversation.api.sinch.com/v1/projects/{projectId}/webhooks/{webhookId}`
   - Extract region and projectId from the configuration
   - Include authorization header with the access token
   - Request body (only include fields that are being updated):
     ```json
     {
       "target": "<new_target_url>",
       "triggers": ["<TRIGGER1>", "<TRIGGER2>"],
       "secret": "<new_secret>"
     }
     ```

5. Report the result:

   - On success: "✅ Webhook updated successfully! ID: {webhook_id}"
   - Display the updated webhook details showing what changed

6. Handle errors gracefully:
   - If MCP configuration is incomplete, report: "Sinch API is not configured. Run `/sinch-conversation-api:sinch-mcp-setup` to see setup instructions."
   - If no update parameters are provided, report: "Please provide at least one field to update (--target, --triggers, or --secret)"
   - If validation fails, provide clear error messages
   - If the API call fails, display the error message with status code and error description

## Examples

Update webhook target URL:

```
/sinch-conversation-api:api:webhooks:update --id=01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z --target=https://new-endpoint.com/webhook
```

Update webhook triggers:

```
/sinch-conversation-api:api:webhooks:update --id=01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z --triggers=MESSAGE_INBOUND,MESSAGE_DELIVERY,MESSAGE_SUBMIT
```

Update webhook secret:

```
/sinch-conversation-api:api:webhooks:update --id=01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z --secret=new-secret-key-123456
```

Update multiple fields at once:

```
/sinch-conversation-api:api:webhooks:update --id=01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z --target=https://new-endpoint.com/webhook --triggers=MESSAGE_INBOUND
```

## Available Triggers

Message-related triggers:

- `MESSAGE_DELIVERY` - Delivery receipts for sent messages
- `MESSAGE_INBOUND` - Inbound messages from end users
- `MESSAGE_SUBMIT` - Message submission events
- `MESSAGE_INBOUND_SMART_CONVERSATION_REDACTION` - Smart conversation redaction events

Other triggers:

- `EVENT_DELIVERY` - Event delivery receipts
- `EVENT_INBOUND` - Inbound events from end users
- `CONVERSATION_START` - New conversation started
- `CONVERSATION_STOP` - Conversation stopped
- `CONVERSATION_DELETE` - Conversation deleted
- `CONTACT_CREATE` - Contact created
- `CONTACT_DELETE` - Contact deleted
- `CONTACT_MERGE` - Contacts merged
- `CONTACT_UPDATE` - Contact updated
- `CONTACT_IDENTITIES_DUPLICATION` - Duplicate contact identities
- `OPT_IN` - User opted in
- `OPT_OUT` - User opted out
- `CAPABILITY` - Channel capability changes
- `CHANNEL_EVENT` - Channel-specific events
- `SMART_CONVERSATION` - Smart conversation events
- `RECORD_NOTIFICATION` - Record notification events
- `UNSUPPORTED` - Unsupported events

## API Reference

- **Endpoint**: `PATCH /v1/projects/{projectId}/webhooks/{webhookId}`
- **Documentation**: https://developers.sinch.com/docs/conversation/api-reference/conversation/tag/Webhooks/#tag/Webhooks/operation/Webhooks_UpdateWebhook

## Request Body Example

```json
{
  "target": "https://new-endpoint.com/webhook",
  "triggers": ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"],
  "secret": "new-webhook-secret"
}
```

## Notes

- Only include fields you want to update in the request
- Target URL must be HTTPS if provided
- When updating triggers, provide the complete new list (it replaces the existing triggers)
- Updating the secret will invalidate the old secret immediately
- The webhook ID cannot be changed
