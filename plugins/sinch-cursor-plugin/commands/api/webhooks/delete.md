---
description: Delete a webhook by ID
allowed-tools:
  - mcp__sinch__sinch-mcp-configuration
argument-hint: --id=<webhook-id> [--confirm]
---

# Delete Webhook

Delete a webhook from your Sinch Conversation API app.

## Input

- `--id`: Webhook ID to delete - required
- `--confirm` / `-y`: Skip confirmation prompt - optional

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS:

   - Validate that `--id` is provided and non-empty
   - Check if `--confirm` flag is present (for skipping confirmation)

2. Call `mcp__sinch__sinch-mcp-configuration` to get the current configuration.

3. Verify the webhook exists:

   - List existing webhooks to verify the webhook ID exists
   - If the webhook doesn't exist, report error: "Webhook with ID '{webhook_id}' not found"
   - Retrieve and display webhook details (target URL, triggers) for confirmation

4. Request confirmation (unless `--confirm` flag is provided):

   - Display the webhook details to be deleted
   - Ask: "Are you sure you want to delete this webhook? (yes/no)"
   - Only proceed if user confirms with "yes" or "y" (case-insensitive)
   - If user declines, report: "Webhook deletion cancelled"

5. Delete the webhook using the Sinch Conversation API:

   - Endpoint: `DELETE https://{region}.conversation.api.sinch.com/v1/projects/{projectId}/webhooks/{webhookId}`
   - Extract region and projectId from the configuration
   - Include authorization header with the access token

6. Report the result:

   - On success: "✅ Webhook deleted successfully! ID: {webhook_id}"
   - Display a summary of the deleted webhook (target URL, triggers it was subscribed to)

7. Handle errors gracefully:
   - If MCP configuration is incomplete, report: "Sinch API is not configured. Run `/sinch-claude-plugin:sinch-mcp-setup` to see setup instructions."
   - If the webhook doesn't exist, report: "Webhook with ID '{webhook_id}' not found"
   - If the API call fails, display the error message with status code and error description

## Examples

Delete a webhook with confirmation:

```
/sinch-claude-plugin:api:webhooks:delete --id=01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z
```

Delete a webhook without confirmation:

```
/sinch-claude-plugin:api:webhooks:delete --id=01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z --confirm
```

Delete a webhook (short form):

```
/sinch-claude-plugin:api:webhooks:delete --id=01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z -y
```

## API Reference

- **Endpoint**: `DELETE /v1/projects/{projectId}/webhooks/{webhookId}`
- **Documentation**: https://developers.sinch.com/docs/conversation/api-reference/conversation/tag/Webhooks/#tag/Webhooks/operation/Webhooks_DeleteWebhook

## Confirmation Display Example

When requesting confirmation, display:

```
Webhook Details:
  ID: 01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z
  Target: https://example.com/webhook
  Triggers: MESSAGE_INBOUND, MESSAGE_DELIVERY
  Target Type: HTTP

Are you sure you want to delete this webhook? (yes/no)
```

## Notes

- Deletion is permanent and cannot be undone
- After deletion, your endpoint will stop receiving webhook events immediately
- If you need to temporarily disable webhooks, consider updating the webhook with different triggers or create a new one later
- Deleting a webhook does not affect message delivery, only event notifications
- Use the `--confirm` flag for automated scripts to skip the confirmation prompt
