---
description: Create a new webhook for the Sinch Conversation API app
allowed-tools:
  - mcp__sinch__sinch-mcp-configuration
argument-hint: --target=<url> --triggers=<trigger1,trigger2,...> [--secret=<secret>]
---

# Create Webhook

Create a new webhook to receive real-time events from the Sinch Conversation API.

## Input

- `--target` / `-t`: Webhook target URL (must be HTTPS) - required
- `--triggers` / `-tr`: Comma-separated list of webhook triggers - required
- `--secret` / `-s`: Secret for webhook signature verification - optional

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS:

   - Validate that `--target` is provided and is a valid HTTPS URL (must start with https://)
   - Validate that `--triggers` is provided and non-empty
   - Parse triggers into an array by splitting on commas and trimming whitespace
   - Normalize each trigger to uppercase (e.g., message_inbound → MESSAGE_INBOUND)
   - Validate that all triggers are valid webhook trigger values (see Available Triggers section)
   - If `--secret` is provided, ensure it's at least 16 characters long

2. Call `mcp__sinch__sinch-mcp-configuration` to get the current configuration.

3. Check for duplicate webhooks:

   - First, list existing webhooks to check if the target URL already exists
   - If a webhook with the same target URL exists, report error: "A webhook with URL '{target}' already exists (ID: {webhook_id})"

4. Create the webhook using the Sinch Conversation API:

   - Endpoint: `POST https://{region}.conversation.api.sinch.com/v1/projects/{projectId}/webhooks`
   - Extract region, projectId, and appId from the configuration
   - Include authorization header with the access token
   - Request body:
     ```json
     {
       "target": "<target_url>",
       "target_type": "HTTP",
       "triggers": ["<TRIGGER1>", "<TRIGGER2>"],
       "secret": "<optional_secret>",
       "app_id": "<appId>"
     }
     ```

5. Report the result:

   - On success: "✅ Webhook created successfully! ID: {webhook_id}"
   - Display the created webhook details (ID, target, triggers)

6. Handle errors gracefully:
   - If MCP configuration is incomplete, report: "Sinch API is not configured. Run `/sinch-claude-plugin:sinch-mcp-setup` to see setup instructions."
   - If validation fails, provide clear error messages about what needs to be fixed
   - If the API call fails, display the error message with status code and error description

## Examples

Create a webhook for inbound messages:

```
/sinch-claude-plugin:api:webhooks:create --target=https://example.com/webhook --triggers=MESSAGE_INBOUND
```

Create a webhook with multiple triggers:

```
/sinch-claude-plugin:api:webhooks:create --target=https://example.com/webhook --triggers=MESSAGE_INBOUND,MESSAGE_DELIVERY --secret=my-secret-key-12345
```

Create a webhook with message-related triggers:

```
/sinch-claude-plugin:api:webhooks:create -t https://example.com/webhook -tr MESSAGE_INBOUND,MESSAGE_DELIVERY,MESSAGE_SUBMIT
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

- **Endpoint**: `POST /v1/projects/{projectId}/webhooks`
- **Documentation**: https://developers.sinch.com/docs/conversation/api-reference/conversation/tag/Webhooks/#tag/Webhooks/operation/Webhooks_CreateWebhook

## Request Body Example

```json
{
  "target": "https://example.com/webhook",
  "target_type": "HTTP",
  "triggers": ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"],
  "secret": "your-webhook-secret",
  "app_id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z"
}
```

## Notes

- Target URL must be HTTPS for security
- Webhooks are app-specific
- The secret is used for verifying webhook signatures to ensure authenticity
- You can subscribe to multiple triggers in a single webhook
- Test your webhook endpoint before creating to ensure it's accessible
