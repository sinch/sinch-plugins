# Sinch Cursor Plugin

Cursor plugin for Sinch Conversation API enabling SMS, RCS, and multi-channel messaging directly from your IDE.

## Overview

This plugin integrates Sinch Conversation API with Cursor IDE, allowing you to:

- Send SMS and RCS messages
- Manage webhooks for message delivery and inbound events
- List active senders and phone numbers
- Handle multi-channel messaging with automatic fallback
- Support for text, media, location, choice, and template messages

## Installation

Install from the Cursor plugin marketplace:

```
/add-plugin sinch-cursor-plugin
```

## Configuration

After installation, configure the required environment variables for the Sinch MCP server.

### Required Environment Variables

You need to configure the following 5 environment variables:

- `CONVERSATION_PROJECT_ID` - Your Sinch project ID
- `CONVERSATION_KEY_ID` - Your API key ID
- `CONVERSATION_KEY_SECRET` - Your API key secret
- `CONVERSATION_REGION` - Your Sinch region (`us`, `eu`, or `br`)
- `CONVERSATION_APP_ID` - Your Conversation app ID

### Getting Sinch Credentials

1. **Create a Sinch Build account**: [Sign up instructions](https://community.sinch.com/t5/Build-Dashboard/How-to-sign-up-for-your-free-Sinch-account/ta-p/8058)
2. **Enable Conversation API**: [Dashboard](https://dashboard.sinch.com/convapi/overview)
3. **Generate an access key**: [Access key guide](https://community.sinch.com/t5/Conversation-API/How-to-get-your-access-key-for-Conversation-API/ta-p/8120)

### Setting Environment Variables in Cursor

1. Open Cursor Settings (Cmd+, on Mac or Ctrl+, on Windows/Linux)
2. Navigate to the environment configuration section
3. Add the following variables:

```json
{
  "env": {
    "CONVERSATION_PROJECT_ID": "your-project-id",
    "CONVERSATION_KEY_ID": "your-key-id",
    "CONVERSATION_KEY_SECRET": "your-key-secret",
    "CONVERSATION_REGION": "us",
    "CONVERSATION_APP_ID": "your-app-id"
  }
}
```

4. Restart Cursor IDE for the changes to take effect

## Usage

Once installed and configured, you can use the plugin in two ways:

### Natural Language (Skills)

The plugin includes AI skills that let you describe what you want in natural language:

```
"Send an SMS to +14155551234 saying 'Hello'"
"Verify a phone number using Sinch Verification API"
"List my available phone numbers"
"Create a 10DLC campaign"
"Send an email via Mailgun"
```

The AI will automatically use the appropriate Sinch API commands and follow best practices.

### Direct Commands

You can also use specific slash commands for precise control:

**Send a message:**
```
/sinch-cursor-plugin:api:messages:send --to=+14155551234 --message="Hello from Cursor!"
```

**Send with channel fallback:**
```
/sinch-cursor-plugin:api:messages:send --to=+14155551234 --message="Hello" --fallback=RCS,SMS
```

**List webhooks:**
```
/sinch-cursor-plugin:api:webhooks:list
```

**Create a webhook:**
```
/sinch-cursor-plugin:api:webhooks:create --url=https://example.com/webhook --triggers=MESSAGE_DELIVERY,MESSAGE_INBOUND
```

## Skills

The plugin includes comprehensive skills for all major Sinch products:

### Messaging & Communication
- **conversation-api** - SMS, RCS, and multi-channel messaging
- **voice-api** - Voice calling and conference management
- **verification-api** - Phone number verification
- **in-app-calling** - In-app voice and video calling
- **fax** - Fax sending and receiving

### Phone Numbers & Provisioning
- **numbers** - Phone number provisioning and management
- **number-lookup** - Phone number information lookup
- **10dlc** - 10DLC campaign registration and management
- **elastic-sip-trunking** - SIP trunking configuration
- **provisioning-api** - Number provisioning automation

### Email Services
- **mailgun** - Email delivery via Mailgun
- **mailgun-inspect** - Email tracking and analytics
- **mailgun-optimize** - Email deliverability optimization
- **mailgun-validate** - Email address validation

### Authentication
- **authentication** - Sinch authentication and credentials

## Available Commands

### Messages
- `/sinch-cursor-plugin:api:messages:send` - Send text, media, location, choice, or template messages

### Senders
- `/sinch-cursor-plugin:api:senders:list` - List active phone numbers and senders

### Webhooks
- `/sinch-cursor-plugin:api:webhooks:list` - List all configured webhooks
- `/sinch-cursor-plugin:api:webhooks:create` - Create a new webhook
- `/sinch-cursor-plugin:api:webhooks:update` - Update an existing webhook
- `/sinch-cursor-plugin:api:webhooks:delete` - Delete a webhook
- `/sinch-cursor-plugin:api:webhooks:triggers` - List available webhook triggers

### Configuration
- `/sinch-cursor-plugin:config:sinch-mcp-setup` - Get setup instructions
- `/sinch-cursor-plugin:sinch-help` - Get general plugin help

## MCP Server Integration

This plugin uses the [@sinch/mcp](https://github.com/sinch/sinch-mcp-server) MCP server for Conversation API integration. The server provides:

- Message sending (text, media, location, choice, template)
- Batch messaging (up to 1000 recipients)
- Template management
- Contact management
- Channel capability checking

## Troubleshooting

### MCP tool not available
- Ensure all 5 environment variables are configured correctly
- Verify variable names match exactly (case-sensitive)
- Restart Cursor IDE after configuration changes
- Check MCP server installation: `npx @sinch/mcp --version`

### Authentication errors
- Verify `CONVERSATION_KEY_ID` and `CONVERSATION_KEY_SECRET` are correct
- Check that the access key has appropriate permissions in Sinch dashboard
- Ensure the key is not expired or revoked

### Channel not configured
- Verify your Conversation app has the channel (SMS/RCS) enabled
- Check channel configuration in [Sinch Dashboard](https://dashboard.sinch.com/convapi/apps)
- For SMS: Ensure a sender number is configured

### Region mismatch
- Verify `CONVERSATION_REGION` matches your project provisioning
- Common values: `us`, `eu`, `br`
- Check in Project Settings in the dashboard

## Links

- [Sinch Conversation API Documentation](https://developers.sinch.com/docs/conversation/)
- [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server)
- [Sinch Dashboard](https://dashboard.sinch.com/)
- [Community Support](https://community.sinch.com/)

## License

Apache-2.0

Copyright 2026 Sinch

Licensed under the Apache License, Version 2.0. See LICENSE file for details.

