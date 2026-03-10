---
name: manage-webhook
description: Manage webhooks in Sinch Conversation API. Use when the user wants to create a webhook, update webhook settings, list webhooks, delete a webhook, get webhook details, configure webhook triggers, or manage webhook callbacks. Handles webhook lifecycle management including creation, updates, deletion, and trigger configuration.
---

# Webhook Management

Manage webhooks in Sinch Conversation API using the Conversation API specification. Note: MCP tools do not provide webhook management tools, so this skill always uses the Conversation API endpoints. Webhooks receive callbacks for various events like message delivery, inbound messages, contact updates, and conversation events.

## Instructions

1. **Identify the operation from user request:**
   - **Create webhook**: New webhook with target URL and triggers
   - **Update webhook**: Modify webhook target, triggers, or secret
   - **List webhooks**: Retrieve webhooks for an app or project
   - **Get webhook**: Retrieve specific webhook details
   - **Delete webhook**: Remove a webhook

2. **Extract webhook information:**
   - Webhook ID: Unique identifier for existing webhooks
   - Target URL: The callback URL where webhooks will be sent
   - App ID: The app this webhook belongs to (required for creation)
   - Triggers: Array of webhook triggers (MESSAGE_DELIVERY, MESSAGE_INBOUND, CONTACT_CREATE, etc.)
   - Secret: Optional secret for signing webhook payloads
   - Target type: HTTP (default) or DISMISS

3. **Use Conversation API endpoints to perform operations:**
   - **Note**: MCP Sinch does not provide webhook management tools, so this skill always uses the Conversation API endpoints
   - **Create webhook**: `POST /v1/projects/{project_id}/webhooks` (Operation ID: `Webhooks_CreateWebhook`)
   - **Update webhook**: `PATCH /v1/projects/{project_id}/webhooks/{webhook_id}` (Operation ID: `Webhooks_UpdateWebhook`)
   - **Get webhook**: `GET /v1/projects/{project_id}/webhooks/{webhook_id}` (Operation ID: `Webhooks_GetWebhook`)
   - **List webhooks**: `GET /v1/projects/{project_id}/apps/{app_id}/webhooks` (Operation ID: `Webhooks_ListWebhooks`)
   - **Delete webhook**: `DELETE /v1/projects/{project_id}/webhooks/{webhook_id}` (Operation ID: `Webhooks_DeleteWebhook`)
   - Authentication: Use Basic Auth or OAuth2 with credentials from environment variables
   - Region: Use CONVERSATION_REGION environment variable (us, eu, or br)
   - Base URL: `https://{region}.conversation.api.sinch.com`

4. **Response handling:**
   - Confirm successful operations with webhook ID
   - Display webhook information clearly (target URL, triggers, app ID)
   - Show webhook configuration details
   - Report errors with actionable guidance

## Examples

**Natural language prompts that trigger this Skill:**
- "Create a webhook for https://example.com/webhook with MESSAGE_DELIVERY trigger"
- "List all webhooks for app abc123"
- "Update webhook xyz789 to add MESSAGE_INBOUND trigger"
- "Delete webhook with ID webhook-123"
- "Show me webhook details for webhook-456"
- "Add CONTACT_CREATE trigger to my webhook"
- "What webhooks are configured for this app?"

**Conversation API Usage (Required - no MCP alternative):**
1. **Note**: MCP Sinch does not provide webhook management tools, so this skill always uses the Conversation API
2. Use the Conversation API endpoints for webhook operations (see endpoints above)
3. Authentication: Use Basic Auth with CONVERSATION_KEY_ID and CONVERSATION_KEY_SECRET, or OAuth2
4. Include required headers: `Authorization`, `Content-Type: application/json`
5. For create webhook, include request body with `app_id` (required), `target`, `target_type` (HTTP or DISMISS), `triggers` array, and optional `secret`
6. For update webhook, use PATCH with `update_mask` parameter to specify which fields to update
7. Maximum 5 webhooks per app

## Webhook Triggers

Available webhook triggers (22 total):

**Message:** `MESSAGE_INBOUND`, `MESSAGE_DELIVERY`, `MESSAGE_SUBMIT`, `MESSAGE_INBOUND_SMART_CONVERSATION_REDACTION`

**Event:** `EVENT_INBOUND`, `EVENT_DELIVERY`

**Conversation:** `CONVERSATION_START`, `CONVERSATION_STOP`, `CONVERSATION_DELETE`

**Contact:** `CONTACT_CREATE`, `CONTACT_UPDATE`, `CONTACT_DELETE`, `CONTACT_MERGE`, `CONTACT_IDENTITIES_DUPLICATION`

**Capability & Opt:** `CAPABILITY`, `OPT_IN`, `OPT_OUT`

**System:** `CHANNEL_EVENT`, `BATCH_STATUS_UPDATE`, `RECORD_NOTIFICATION`, `SMART_CONVERSATION`, `UNSUPPORTED`

## Webhook Operations

### Create Webhook
- Requires `app_id` in request body
- Specify `target` URL (must be HTTPS for production)
- Set `target_type` (HTTP or DISMISS)
- Configure `triggers` array with one or more trigger types
- Optional `secret` for signing webhook payloads
- Maximum 5 webhooks per app

### Update Webhook
- Use PATCH method with `update_mask` parameter
- Can update `target`, `triggers`, `secret`, `target_type`
- Include only fields to update in request body

### List Webhooks
- List webhooks for a specific app: `GET /v1/projects/{project_id}/apps/{app_id}/webhooks`
- Returns array of webhooks with their configuration

### Get Webhook
- Retrieve specific webhook by ID
- Returns full webhook configuration including triggers and target

### Delete Webhook
- Remove webhook by ID
- Webhook will stop receiving callbacks immediately

## HMAC Signature Validation

When a webhook has a `secret` configured, Sinch signs each payload using HMAC-SHA256. Verify authenticity using these headers:

- `x-sinch-webhook-signature` — the HMAC signature
- `x-sinch-webhook-signature-timestamp` — Unix timestamp of the signature
- `x-sinch-webhook-signature-nonce` — unique nonce per request
- `x-sinch-webhook-signature-algorithm` — algorithm used (HMAC-SHA256)

**Signature format:** `HMAC-SHA256(rawBody + '.' + nonce + '.' + timestamp, secret)`

Always verify the signature before processing webhook payloads in production.

## Webhook Scripts

Pre-built scripts for webhook management:

```bash
node scripts/webhooks/create_webhook.cjs --app-id APP_ID --target https://your-server.com/webhook --triggers MESSAGE_INBOUND,MESSAGE_DELIVERY
node scripts/webhooks/list_webhooks.cjs --app-id APP_ID
node scripts/webhooks/get_webhook.cjs --webhook-id WEBHOOK_ID
node scripts/webhooks/update_webhook.cjs --webhook-id WEBHOOK_ID --target https://new-url.com/webhook --triggers MESSAGE_INBOUND
node scripts/webhooks/delete_webhook.cjs --webhook-id WEBHOOK_ID
node scripts/webhooks/test_webhook_triggers.cjs --webhook-id WEBHOOK_ID --test-url https://webhook.site/your-id
```

Requires environment variables: `SINCH_PROJECT_ID`, `SINCH_KEY_ID`, `SINCH_KEY_SECRET`, `SINCH_REGION`.

## Code Generation References

Multi-language webhook examples:

- **Create:** [references/webhooks/create/](references/webhooks/create/) — JavaScript, Python, Java
- **List:** [references/webhooks/list/](references/webhooks/list/)
- **Get:** [references/webhooks/get/](references/webhooks/get/)
- **Update:** [references/webhooks/update/](references/webhooks/update/)
- **Delete:** [references/webhooks/delete/](references/webhooks/delete/)

Webhook trigger reference docs:

- [references/webhooks/triggers/message-inbound.md](references/webhooks/triggers/message-inbound.md)
- [references/webhooks/triggers/message-delivery.md](references/webhooks/triggers/message-delivery.md)
- [references/webhooks/triggers/message-submit.md](references/webhooks/triggers/message-submit.md)
- [references/webhooks/triggers/event-inbound.md](references/webhooks/triggers/event-inbound.md)
- [references/webhooks/triggers/event-delivery.md](references/webhooks/triggers/event-delivery.md)
- [references/webhooks/triggers/conversation-lifecycle.md](references/webhooks/triggers/conversation-lifecycle.md)
- [references/webhooks/triggers/contact-management.md](references/webhooks/triggers/contact-management.md)
- [references/webhooks/triggers/capability.md](references/webhooks/triggers/capability.md)
- [references/webhooks/triggers/opt-inout.md](references/webhooks/triggers/opt-inout.md)
- [references/webhooks/triggers/smart-conversations.md](references/webhooks/triggers/smart-conversations.md)
- [references/webhooks/triggers/system-events.md](references/webhooks/triggers/system-events.md)

## Notes

- **MCP Note**: MCP Sinch does not provide webhook management tools, so this skill always uses the Conversation API endpoints
- Maximum 5 webhooks per app
- Webhook target URLs should use HTTPS in production
- Webhook secret is optional but recommended for verifying webhook authenticity via HMAC-SHA256
- Triggers can be combined — a webhook can subscribe to multiple trigger types
- Webhooks are scoped to apps — each webhook belongs to a specific app
- Use the Conversation API endpoints directly — reference the OpenAPI spec for exact parameter names and types
- Webhook callbacks are sent as HTTP POST requests to the target URL
- For testing, you can use HTTP URLs, but production webhooks should use HTTPS
- **Webhook authentication**: Supports both OAuth2.0 and HMAC authentication methods
- **Retry policy**: Sinch automatically retries failed webhook deliveries with exponential backoff

