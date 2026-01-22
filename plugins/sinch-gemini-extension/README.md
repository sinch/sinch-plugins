# Sinch Conversation API - Gemini CLI Extension

A [Gemini CLI extension](https://github.com/google-gemini/gemini-cli) that integrates the Sinch Conversation API, enabling you to send SMS messages directly from Gemini CLI using natural language.

## Features

- **Send SMS Messages**: Send text messages via SMS
- **Media Messages**: Send images, videos, and other media via SMS
- **App Management**: List apps and available messaging templates
- **Natural Language Interface**: Use conversational commands with Gemini AI

## Prerequisites

- [Gemini CLI](https://github.com/google-gemini/gemini-cli) v0.4.0 or higher
- A [Sinch Customer Dashboard](https://dashboard.sinch.com/) account
- A Conversation API app with credentials (Project ID, Key ID, Key Secret, App ID)

## Installation

### Install from GitHub (Recommended)

```bash
gemini extensions install https://github.com/sinch/sinch-plugins
```

### Install from Local Path

```bash
cd sinch-plugins/plugins/sinch-gemini-extension
gemini extensions install .
```

### Install from Git Repository

```bash
gemini extensions install https://github.com/sinch/sinch-plugins
```

## Configuration

### During Installation

When you install the extension, Gemini CLI will automatically prompt you for your Sinch credentials:

- **CONVERSATION_PROJECT_ID**: Your Sinch project ID (required)
- **CONVERSATION_KEY_ID**: Your API key ID (required)
- **CONVERSATION_KEY_SECRET**: Your API key secret (required, stored securely)
- **CONVERSATION_REGION**: Your region (us, eu, or br) (required)
- **CONVERSATION_APP_ID**: Your Sinch Conversation API App ID (required)

### Getting Your Credentials

1. Visit the [Sinch Dashboard](https://dashboard.sinch.com/)
2. Create or select a Conversation API project
3. Create an app and configure SMS channel
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

# Send an SMS
"Send an SMS to +1234567890 with message 'Your order is ready'"

# List your Sinch apps
"List all my Sinch conversation apps"

# Send an SMS with media
"Send an image to +1234567890 via SMS with URL https://example.com/image.jpg"

# List available templates
"Show me all my Sinch message templates"
```

## Available MCP Tools

The extension provides access to these Sinch MCP tools:

- **send-text-message** - Send text messages via SMS
- **send-media-message** - Send media messages (images, videos) via SMS
- **send-template-message** - Send template messages via SMS
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

Verify your Conversation app has the SMS channel configured in the Sinch Dashboard.

### Message Delivery Issues

- Ensure phone numbers are in E.164 format (+country_code + number)
- Verify the recipient's carrier supports SMS
- Check that your app has SMS channel configured and enabled

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

### Send SMS Messages

```bash
# Send a text SMS
"Send an SMS to +1234567890 with the message: Your order #12345 is ready"

# Send an SMS with more context
"Send an SMS to +1234567890: Hello from Sinch!"
```

### Send Media Messages via SMS

```bash
"Send an image via SMS to +1234567890 with this URL: https://example.com/photo.jpg"

"Send a video message to +1234567890 via SMS with URL https://example.com/video.mp4 and caption 'Check this out'"
```

### List and Manage Apps

```bash
"List all my Sinch conversation apps"

"Show me available message templates"

"Check my Sinch app SMS configuration"
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
