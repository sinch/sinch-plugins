# Sinch Conversation API - Gemini CLI Extension

A [Gemini CLI extension](https://github.com/google-gemini/gemini-cli) that integrates the Sinch Conversation API, enabling you to send messages via SMS, WhatsApp, RCS, and other messaging channels directly from Gemini CLI using natural language.

## Features

- **Send Messages**: Send text messages via SMS, WhatsApp, RCS, and other channels
- **Media Messages**: Send images, videos, and other media
- **Location Messages**: Share location information
- **Interactive Messages**: Send choice messages and templates
- **Channel Management**: List apps and available messaging templates
- **Natural Language Interface**: Use conversational commands with Gemini AI

## Prerequisites

- [Gemini CLI](https://github.com/google-gemini/gemini-cli) v0.4.0 or higher
- A [Sinch Customer Dashboard](https://dashboard.sinch.com/) account
- A Conversation API app with credentials (Project ID, Key ID, Key Secret, App ID)

## Installation

### Install from GitHub (Recommended)

```bash
gemini extensions install https://github.com/sinch/sinch-plugins --ref main
```

### Install from Local Path

```bash
gemini extensions install ./plugins/sinch-gemini-extension/.gemini-extension
```

### Install from Git Repository

```bash
gemini extensions install https://gitlab.com/sinch/sinch-projects/applications/smb/teams/partnership_devex/sinch-conversation-claude-plugin.git --ref main
```

## Configuration

### During Installation

When you install the extension, Gemini CLI will automatically prompt you for your Sinch credentials:

- **CONVERSATION_PROJECT_ID**: Your Sinch project ID (required)
- **CONVERSATION_KEY_ID**: Your API key ID (required)
- **CONVERSATION_KEY_SECRET**: Your API key secret (required, stored securely)
- **CONVERSATION_REGION**: Your region (us, eu, or br) (required)
- **CONVERSATION_APP_ID**: Your Sinch Conversation API App ID (required)
- **NGROK_AUTH_TOKEN**: (Optional) Ngrok token - only needed for `get-message-events` tool

**Note:** You can skip `NGROK_AUTH_TOKEN` if you only need to send messages. It's only required for receiving message delivery events/webhooks.

### Getting Your Credentials

1. Visit the [Sinch Dashboard](https://dashboard.sinch.com/)
2. Create or select a Conversation API project
3. Create an app and configure channels (SMS, WhatsApp, RCS, etc.)
4. Generate API credentials (Access Key)
5. Copy the Project ID, Key ID, Key Secret, Region, and App ID

## Verify Installation

After installation, verify the extension is working:

```bash
# List installed extensions
gemini extensions list

# Check MCP server status
gemini mcp list
```

Should show: `✓ sinch: command: npx -y @sinch/mcp (stdio) - Connected`

## Usage

Once installed, you can use Sinch messaging capabilities in Gemini CLI with natural language:

```bash
# Start Gemini CLI
gemini

# Send a WhatsApp message
"Send a WhatsApp message to +1234567890 saying 'Hello from Gemini CLI'"

# List your Sinch apps
"List all my Sinch conversation apps"

# Send an SMS
"Send an SMS to +1234567890 with message 'Your order is ready'"

# Send a message with media
"Send an image to +1234567890 via WhatsApp with URL https://example.com/image.jpg"

# List available templates
"Show me all my Sinch message templates"
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
gemini extensions settings list sinch-gemini-extension
```

### Update a Setting

```bash
gemini extensions settings set sinch-gemini-extension CONVERSATION_PROJECT_ID
gemini extensions settings set sinch-gemini-extension "Key Secret"
```

You can update settings at any time without reinstalling the extension.

## Extension Management

### Update Extension

```bash
# Update this extension
gemini extensions update sinch-gemini-extension

# Update all extensions
gemini extensions update --all
```

### Disable/Enable Extension

```bash
# Disable globally
gemini extensions disable sinch-gemini-extension

# Enable globally
gemini extensions enable sinch-gemini-extension

# Disable for current workspace only
gemini extensions disable sinch-gemini-extension --scope workspace

# Enable for current workspace only
gemini extensions enable sinch-gemini-extension --scope workspace
```

### Uninstall Extension

```bash
gemini extensions uninstall sinch-gemini-extension
```

## Development

## Troubleshooting

### "Environment variables not configured"

Ensure all required environment variables are set via extension settings:

```bash
gemini extensions settings list sinch-gemini-extension
```

If any are missing, set them:

```bash
gemini extensions settings set sinch-gemini-extension CONVERSATION_PROJECT_ID
```

### MCP Server Not Connected

Check MCP server status:

```bash
gemini mcp list
```

If the Sinch MCP server isn't showing as connected, try restarting Gemini CLI.

### Authentication Errors

- Verify your Key ID and Key Secret are correct
- Ensure your access key has not expired
- Check that the region matches your app's region
- Update credentials: `gemini extensions settings set sinch-gemini-extension "Key Secret"`

### Channel Not Configured

Verify your Conversation app has the channel (SMS, WhatsApp, RCS) configured in the Sinch Dashboard.

### Message Delivery Issues

- Ensure phone numbers are in E.164 format (+country_code + number)
- Verify the recipient's carrier supports the channel
- Check that your app has the necessary channel permissions

## Development

### Link Local Extension for Development

If you're developing the extension locally:

```bash
gemini extensions link ./plugins/sinch-gemini-extension/.gemini-extension
```

This creates a symlink so changes are immediately available without reinstalling.

### Extension Structure

```
.gemini-extension/
├── gemini-extension.json    # Extension configuration
└── README.md                # This file
```

## Examples

### Send Messages with Different Channels

```bash
# WhatsApp message
"Send a WhatsApp message to +1234567890: Hello from Sinch!"

# SMS message
"Send an SMS to +1234567890 with the message: Your order #12345 is ready"

# RCS message
"Send an RCS message to +1234567890: Check out our new features!"
```

### Send Media Messages

```bash
"Send an image via WhatsApp to +1234567890 with this URL: https://example.com/photo.jpg"

"Send a video message to +1234567890 via WhatsApp with URL https://example.com/video.mp4 and caption 'Check this out'"
```

### List and Manage Apps

```bash
"List all my Sinch conversation apps"

"Show me available message templates"

"What channels are configured in my Sinch app?"
```

## API References

- [Sinch Conversation API Documentation](https://developers.sinch.com/docs/conversation)
- [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server)
- [Gemini CLI Extensions Documentation](https://geminicli.com/docs/extensions/)
- [Message Templates](https://developers.sinch.com/docs/conversation/templates/)
- [Webhooks Documentation](https://developers.sinch.com/docs/conversation/webhooks/)

## Contributing

Contributions are welcome! Please check the main repository for contribution guidelines.

## License

See the LICENSE file in the repository root.
