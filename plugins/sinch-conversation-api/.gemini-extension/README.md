# Sinch Conversation API - Gemini Extension

This extension integrates Sinch Conversation API with Gemini CLI, enabling you to send messages via SMS, WhatsApp, RCS, and other messaging channels directly from Gemini CLI with natural language.

## Installation

### Install from Local Path

```bash
gemini extensions install ./plugins/sinch-conversation-api/.gemini-extension
```

### Install from Git Repository

```bash
gemini extensions install https://gitlab.com/sinch/sinch-projects/applications/smb/teams/partnership_devex/sinch-conversation-claude-plugin.git --ref main
```

### During Installation

When you install the extension, Gemini CLI will automatically prompt you for your Sinch credentials:

- **CONVERSATION_PROJECT_ID**: Your Sinch project ID (required)
- **CONVERSATION_KEY_ID**: Your API key ID (required)
- **CONVERSATION_KEY_SECRET**: Your API key secret (required, hidden input)
- **CONVERSATION_REGION**: Your region (us, eu, or br) (required)
- **NGROK_AUTH_TOKEN**: (Optional) Ngrok token - only needed for `get-message-events` tool

**Note:** You can skip `NGROK_AUTH_TOKEN` if you only need to send messages. It's only required for receiving message delivery events/webhooks.

## Verification

After installation, verify the extension is working:

```bash
# List installed extensions
gemini extensions list

# Check MCP server status
gemini mcp list
```

## Usage

Once installed, you can use Sinch messaging capabilities in Gemini CLI:

```
# Start Gemini CLI
gemini

# Send a WhatsApp message
"Send a WhatsApp message to +1234567890 saying 'Hello from Gemini CLI'"

# List your Sinch apps
"List all my Sinch conversation apps"

# Send an SMS
"Send an SMS to +1234567890 with message 'Your order is ready'"
```

## Available MCP Tools

The extension provides access to these Sinch MCP tools:

- **send-text-message** - Send text messages via WhatsApp, SMS, RCS, etc.
- **send-media-message** - Send media messages (images, videos)
- **send-location-message** - Send location messages
- **send-choice-message** - Send interactive choice messages
- **send-template-message** - Send template messages
- **list-conversation-apps** - List configured apps and channels
- **list-messaging-templates** - List available message templates
- **sinch-mcp-configuration** - Check MCP server configuration status

## Managing Settings

### View Extension Settings

```bash
gemini extensions settings list sinch-conversation-api
```

### Update a Setting

```bash
gemini extensions settings set sinch-conversation-api CONVERSATION_PROJECT_ID
```

## Extension Management

### Update Extension

```bash
# Update this extension
gemini extensions update sinch-conversation-api

# Update all extensions
gemini extensions update --all
```

### Disable Extension

```bash
# Disable globally
gemini extensions disable sinch-conversation-api

# Disable for current workspace only
gemini extensions disable sinch-conversation-api --scope workspace
```

### Enable Extension

```bash
# Enable globally
gemini extensions enable sinch-conversation-api

# Enable for current workspace only
gemini extensions enable sinch-conversation-api --scope workspace
```

### Uninstall Extension

```bash
gemini extensions uninstall sinch-conversation-api
```

## Development

### Link Local Extension for Development

If you're developing the extension locally:

```bash
gemini extensions link ./plugins/sinch-conversation-api/.gemini-extension
```

This creates a symlink so changes are immediately available without reinstalling.

### Extension Structure

```
.gemini-extension/
├── gemini-extension.json    # Extension configuration
└── README.md                # This file
```

## References

- [Gemini CLI Extensions Documentation](https://geminicli.com/docs/extensions/)
- [Sinch Conversation API Documentation](https://developers.sinch.com/docs/conversation)
- [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server)
