---
description: List all webhooks for the configured Sinch Conversation API app
allowed-tools:
  - mcp__sinch__sinch-mcp-configuration
argument-hint: [--format=json|table]
---

# List Webhooks

List all webhooks configured for your Sinch Conversation API app.

## Input

- `--format` / `-f`: Output format (json or table) - optional, defaults to table

$ARGUMENTS

## Instructions

1. Parse and validate arguments from $ARGUMENTS:

   - If `--format` is not provided, default to "table"
   - Validate that format is either "json" or "table"
   - Normalize format to lowercase

2. Call `mcp__sinch__sinch-mcp-configuration` to get the current configuration and verify setup.

3. Use the Sinch Conversation API to list webhooks:

   - Endpoint: `GET https://{region}.conversation.api.sinch.com/v1/projects/{projectId}/apps/{appId}/webhooks`
   - Extract region, projectId, and appId from the configuration
   - Include authorization header with the access token

4. Display the results based on the requested format:

   - **Table format**: Display a formatted table with columns: ID, Target URL, Triggers (comma-separated), Target Type
   - **JSON format**: Display the raw JSON response

5. Handle errors gracefully:
   - If MCP configuration is incomplete, report: "Sinch API is not configured. Run `/sinch-claude-plugin:sinch-mcp-setup` to see setup instructions."
   - If the API call fails, display the error message with relevant details (status code, error description)
   - If no webhooks are found, display: "No webhooks found for this app."

## Examples

List webhooks in table format:

```
/sinch-claude-plugin:api:webhooks:list
```

List webhooks in JSON format:

```
/sinch-claude-plugin:api:webhooks:list --format=json
```

## API Reference

- **Endpoint**: `GET /v1/projects/{projectId}/apps/{appId}/webhooks`
- **Documentation**: https://developers.sinch.com/docs/conversation/api-reference/conversation/tag/Webhooks/#tag/Webhooks/operation/Webhooks_ListWebhooks

## Response Structure

```json
{
  "webhooks": [
    {
      "id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z",
      "target": "https://example.com/webhook",
      "target_type": "HTTP",
      "triggers": ["MESSAGE_INBOUND", "MESSAGE_DELIVERY"],
      "secret": "***",
      "app_id": "01E9DQJFPWGZ4N9XQ3FZ8Z8Z8Z"
    }
  ]
}
```

## Notes

- Webhooks are app-specific, so make sure you have the correct app selected in your configuration
- The secret field will be partially masked for security
- Available regions: us, eu, br
