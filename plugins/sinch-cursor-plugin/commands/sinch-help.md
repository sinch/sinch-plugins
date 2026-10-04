---
name: sinch-help
description: Get instructions for configuring Sinch Conversation API environment variables
---

# Sinch Conversation API Setup

Configure the required environment variables to enable the Sinch Conversation API MCP server in Cursor.

## Overview

This plugin uses the Sinch Conversation API MCP server (defined in `mcp.json`) to send and receive messages via SMS and RCS channels. It supports multiple message types (text, media, location, choice, template), batch messaging (up to 1000 recipients), template management, and channel fallback.

For more details about the underlying MCP server and tools, see [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server)

## Required Environment Variables

You need to obtain and configure the following 5 variables:

- `PROJECT_ID` - Your Sinch project ID
- `KEY_ID` - Your API key ID
- `KEY_SECRET` - Your API key secret
- `CONVERSATION_REGION` - Your Sinch region (e.g., `us`, `eu`, `br`)
- `CONVERSATION_APP_ID` - Your Conversation app ID

## Get Your Sinch Credentials

- Create a Sinch Build account ([see here for instructions on setting up an account](https://community.sinch.com/t5/Build-Dashboard/How-to-sign-up-for-your-free-Sinch-account/ta-p/8058)).
- Enable the product in the dashboard: [Conversation API](https://dashboard.sinch.com/convapi/overview).
- Generate an access key in the [Sinch Build Dashboard](https://dashboard.sinch.com/settings/access-keys). If you need help, [review our Community article on access key creation](https://community.sinch.com/t5/Conversation-API/How-to-get-your-access-key-for-Conversation-API/ta-p/8120).

## Configuration Steps

### 1. Run the Setup Command

The quickest way is `/sinch-mcp-setup`, which can generate a setup script that writes the credentials file for you. To do it by hand, follow steps 2 and 3.

### 2. Create the Credentials File

The MCP server reads its credentials from `~/.sinch/mcp.env`. Create it and restrict it to your user:

```bash
mkdir -p ~/.sinch && chmod 700 ~/.sinch
touch ~/.sinch/mcp.env && chmod 600 ~/.sinch/mcp.env
```

Add your credentials, one per line, with no quotes:

```
PROJECT_ID=your-project-id-here
KEY_ID=your-key-id-here
KEY_SECRET=your-key-secret-here
CONVERSATION_REGION=us
CONVERSATION_APP_ID=your-app-id-here
```

**Important:** Replace the placeholder values with your actual Sinch credentials. `CONVERSATION_REGION` is `us`, `eu` or `br`.

### 3. Restart the MCP Server

Restart the `sinch` server in Cursor Settings → MCP, or reload the window.

### 4. Verify Setup

Test your configuration by sending a message:

```
/sinch-claude-plugin:api:messages:send --to=+14155551234 --message="Test message"
```

If the MCP server is configured correctly, the message will be sent. If you encounter errors, double-check:

- All 5 environment variables are set
- Values are correct (no typos)
- The `sinch` MCP server has been restarted
- Your Sinch app has the appropriate channel configured

## Troubleshooting

**"MCP tool is not available"** - Environment variables are missing or incorrect. Review steps 1-3 above.

**Authentication errors** - Verify your `KEY_ID` and `KEY_SECRET` are correct.

**Channel not configured** - Ensure your Conversation app (identified by `CONVERSATION_APP_ID`) has the channel you're trying to use enabled in the Sinch dashboard.

## Next Steps

Once configured, you can use these commands:

### Skills (Natural Language Workflows)

Skills let you describe what you want in plain English, and the plugin will run the right actions.

Important: Skills will only call MCP tools if your Sinch environment variables (`PROJECT_ID`, `KEY_ID`, `KEY_SECRET`, `CONVERSATION_REGION`, `CONVERSATION_APP_ID`) are set in `~/.sinch/mcp.env` and the Sinch MCP server is up and running.

Available skills (each includes bundled scripts and reference docs):

- [Send Message](../skills/send-message/SKILL.md) — scripts for SMS/RCS sending, channel guides, multi-language code examples, template and batch references
- [Channel Info](../skills/channel-info/SKILL.md) — channel-specific reference guides (SMS, RCS)
- [List Messages](../skills/list-messages/SKILL.md) — list messages script, multi-language code examples
- [Manage Contact](../skills/manage-contact/SKILL.md) — contact CRUD operations
- [Manage Webhook](../skills/manage-webhook/SKILL.md) — webhook CRUD scripts, trigger payload references, multi-language code examples

Example prompts:

- "Send an SMS to +14155551234 saying 'Hello'"
- "Send an RCS message to +14155551234 with fallback to SMS"
- "Send a template message to +14155551234"
- "List my last 10 messages"
- "Create a webhook for MESSAGE_DELIVERY to https://example.com/webhook"
- "What channels can I use to reach +14155551234?"

**Messages:**

- `/sinch-claude-plugin:api:messages:send` - Send messages (text, media, location, choice, template) via SMS and RCS with optional channel fallback

**Senders:**

- `/sinch-claude-plugin:api:senders:list` - List active phone numbers/senders (SDK and direct API examples in Node.js, Python, Java)

**Webhooks:**

- `/sinch-claude-plugin:api:webhooks:list` - List all webhooks
- `/sinch-claude-plugin:api:webhooks:create` - Create a new webhook
- `/sinch-claude-plugin:api:webhooks:update` - Update an existing webhook
- `/sinch-claude-plugin:api:webhooks:delete` - Delete a webhook
- `/sinch-claude-plugin:api:webhooks:triggers` - List message-related webhook triggers
