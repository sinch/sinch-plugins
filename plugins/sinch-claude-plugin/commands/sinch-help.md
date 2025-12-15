---
name: sinch-help
description: Get instructions for configuring Sinch Conversation API environment variables
---

# Sinch Conversation API Setup

Configure the required environment variables to enable the Sinch Conversation API MCP server in Claude Code.

## Overview

This plugin uses the Sinch Conversation API MCP server (defined in `.mcp.json`) to send messages via SMS, WhatsApp, RCS, and other channels. To use these commands, you need to add your Sinch credentials as environment variables in Claude Code's settings.
For more details about the underlying MCP server and tools, see [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server)

## Required Environment Variables

You need to obtain and configure the following 5 variables:

- `CONVERSATION_PROJECT_ID` - Your Sinch project ID
- `CONVERSATION_KEY_ID` - Your API key ID
- `CONVERSATION_KEY_SECRET` - Your API key secret
- `CONVERSATION_REGION` - Your Sinch region (e.g., `us`, `eu`, `br`)
- `CONVERSATION_APP_ID` - Your Conversation app ID

Optionally, you can also set:

- `NGROK_AUTH_TOKEN` - Your Ngrok authentication token if you want to use the tool get-message-events, you have to be able to receive events related to a message.

## How to Get Credentials

Visit the [Sinch Conversation API documentation](https://developers.sinch.com/docs/conversation) to:

- Create a Sinch account
- Set up a Conversation API project
- Create an app and configure channels
- Generate API credentials (Key ID and Secret)

## Configuration Steps

### 1. Open Claude Code Settings

On macOS, the settings file is located at:

```
~/.claude/settings.json
```

You can open it by:

- Using a text editor: `code ~/.claude/settings.json` or `open -a TextEdit ~/.claude/settings.json`
- Using Finder: Press `Cmd+Shift+G` and paste `~/.claude/settings.json`

### 2. Add Environment Variables

Add or update the `env` section in your `settings.json`:

```json
{
  "env": {
    "CONVERSATION_PROJECT_ID": "your-project-id-here",
    "CONVERSATION_KEY_ID": "your-key-id-here",
    "CONVERSATION_KEY_SECRET": "your-key-secret-here",
    "CONVERSATION_REGION": "your-app-region (e.g., us, eu, br)",
    "CONVERSATION_APP_ID": "your-app-id-here"
  }
}
```

**Important:** Replace the placeholder values with your actual Sinch credentials.

### 3. Restart Claude Code

After saving the settings file, restart Claude Code for the changes to take effect.

### 4. Verify Setup

Test your configuration by sending a message:

```
/sinch-claude-plugin:api:messages:send --to=+14155551234 --message="Test message"
```

If the MCP server is configured correctly, the message will be sent. If you encounter errors, double-check:

- All 5 environment variables are set
- Values are correct (no typos)
- Claude Code has been restarted
- Your Sinch app has the appropriate channel configured

## Troubleshooting

**"MCP tool is not available"** - Environment variables are missing or incorrect. Review steps 1-3 above.

**Authentication errors** - Verify your `CONVERSATION_KEY_ID` and `CONVERSATION_KEY_SECRET` are correct.

**Channel not configured** - Ensure your Conversation app (identified by `CONVERSATION_APP_ID`) has the channel you're trying to use enabled in the Sinch dashboard.

## Next Steps

Once configured, you can use these commands:

### Skills (Natural Language Workflows)

Skills let you describe what you want in plain English, and the plugin will run the right actions.

Important: Skills will only call MCP tools if your `CONVERSATION_*` environment variables are configured in Claude Code and the Sinch MCP server is up and running.

Available skills:

- [Send Message](../skills/send-message/SKILL.md)
- [Channel Info](../skills/channel-info/SKILL.md)
- [List Messages](../skills/list-messages/SKILL.md)
- [Manage Contact](../skills/manage-contact/SKILL.md)
- [Manage Webhook](../skills/manage-webhook/SKILL.md)

Example prompts:

- "Send a SMS message to +14155551234 saying 'Hello'"
- "List my last 10 messages"
- "Create a webhook for MESSAGE_DELIVERY to https://example.com/webhook"

**Messages:**

- `/sinch-claude-plugin:api:messages:send` - Send text messages
- `/sinch-claude-plugin:api:messages:status` - Check message delivery status

**Senders:**

- `/sinch-claude-plugin:api:senders:list` - List active phone numbers/senders

**Webhooks:**

- `/sinch-claude-plugin:api:webhooks:list` - List all webhooks
- `/sinch-claude-plugin:api:webhooks:create` - Create a new webhook
- `/sinch-claude-plugin:api:webhooks:update` - Update an existing webhook
- `/sinch-claude-plugin:api:webhooks:delete` - Delete a webhook
- `/sinch-claude-plugin:api:webhooks:triggers` - List message-related webhook triggers
