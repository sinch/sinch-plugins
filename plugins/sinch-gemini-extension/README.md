# Sinch - Gemini CLI Extension

A [Gemini CLI extension](https://github.com/google-gemini/gemini-cli) that integrates Sinch APIs: Conversation API (SMS, RCS, WhatsApp), Voice, Verification, Fax, Numbers, 10DLC, Email (Mailgun, Mailjet), and more. Use natural language or slash commands to send messages, make calls, verify numbers, send faxes, and manage configuration.

## Features

- **Messaging**: Send text, media, rich cards, carousels, choices, and location via SMS, RCS, WhatsApp; list messages and senders
- **Webhooks**: Create, list, update, delete webhooks; view trigger reference
- **Batch & Templates**: Send batch messages (up to 1000 recipients); list, create, delete message templates
- **Voice & Verification**: Place TTS callouts; start phone verification (SMS/Flashcall/Call) and check codes
- **Fax & Numbers**: Send and list faxes; number lookup (carrier, etc.); search available numbers to rent
- **Email**: Send and validate/inspect/optimize with Mailgun; send with Mailjet
- **Infrastructure**: 10DLC brands and campaigns; Elastic SIP trunks; Provisioning (WhatsApp/RCS senders); list contacts
- **Help**: Authentication setup guide and command overview (`/sinch:help`, `/sinch:config:auth`)
- **Natural language**: Use conversational prompts or slash commands with Gemini AI

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
cd skills/plugins/sinch-gemini-extension
gemini extensions install .
```

### Install from Git Repository

```bash
gemini extensions install https://github.com/sinch/sinch-plugins
```

## Configuration

### During Installation

When you install the extension, Gemini CLI will prompt you for credentials. At minimum, set Conversation API credentials for messaging:

- **CONVERSATION_PROJECT_ID**: Your Sinch project ID (required for messaging, batch, templates, webhooks, numbers, fax, 10DLC, provisioning, contacts)
- **CONVERSATION_KEY_ID**: Your API key ID (required)
- **CONVERSATION_KEY_SECRET**: Your API key secret (required, stored securely)
- **CONVERSATION_REGION**: Your region (us, eu, or br) (required)
- **CONVERSATION_APP_ID**: Your Sinch Conversation API App ID (required for sending messages)

### Optional Settings (per product)

- **Voice API**: VOICE_APPLICATION_KEY, VOICE_APPLICATION_SECRET (for `/sinch:api:voice:*`)
- **Verification API**: VERIFICATION_APPLICATION_KEY, VERIFICATION_APPLICATION_SECRET (for `/sinch:api:verification:*`)
- **Mailgun**: MAILGUN_API_KEY, MAILGUN_DOMAIN, MAILGUN_REGION (us/eu) (for `/sinch:email:mailgun:*`)
- **Mailjet**: MJ_APIKEY_PUBLIC, MJ_APIKEY_PRIVATE (for `/sinch:email:mailjet:*`)

### Getting Your Credentials

1. Visit the [Sinch Dashboard](https://dashboard.sinch.com/)
2. **Conversation API**: Create a project, create an app, configure channels (SMS, RCS, etc.), create an Access Key (Project ID, Key ID, Key Secret, Region, App ID).
3. **Voice / Verification**: Use Application Key + Secret from the respective app in the dashboard.
4. **Mailgun / Mailjet**: Use API keys from the Mailgun or Mailjet account (by Sinch) dashboards.
5. Run `/sinch:config:auth` in Gemini CLI for a full authentication guide.

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

Start Gemini CLI (`gemini`) and use natural language or slash commands. Run `/sinch:help` for a full command overview.

### Slash commands (examples)

| Category | Commands |
|----------|----------|
| **Messages** | `/sinch:api:messages:send`, `send-media`, `send-card`, `send-carousel`, `send-choice`, `send-location`, `list` |
| **Webhooks** | `/sinch:api:webhooks:create`, `list`, `update`, `delete`, `triggers` |
| **Senders** | `/sinch:api:senders:list` |
| **Batch** | `/sinch:api:batch:send`, `status` |
| **Templates** | `/sinch:api:templates:list`, `create`, `delete` |
| **Voice** | `/sinch:api:voice:callout`, `calls` |
| **Verification** | `/sinch:api:verification:start`, `check` |
| **Fax** | `/sinch:api:fax:send`, `list` |
| **Numbers** | `/sinch:api:numbers:lookup`, `search` |
| **10DLC** | `/sinch:api:10dlc:brands`, `campaigns` |
| **SIP** | `/sinch:api:sip:trunks` |
| **Provisioning** | `/sinch:api:provisioning:setup` |
| **Contacts** | `/sinch:api:contacts:list` |
| **Email** | `/sinch:email:mailgun:send`, `validate`, `inspect`, `optimize`; `/sinch:email:mailjet:send` |
| **Config** | `/sinch:config:auth`, `/sinch:help` |

### Natural language examples

```bash
# Start Gemini CLI
gemini

# Send an SMS
"Send an SMS to +1234567890 with message 'Your order is ready'"

# List your Sinch apps
"List all my Sinch conversation apps"

# Send media, start verification, send fax
"Send an image to +1234567890 via SMS with URL https://example.com/image.jpg"
"Start SMS verification for +1234567890"
"Send a fax to +1234567890 from https://example.com/doc.pdf"

# Email (with Mailgun/Mailjet configured)
"Send an email via Mailgun to user@example.com with subject Hello and body Hi there"
```

## Available MCP Tools

When the Sinch MCP server is connected, these tools are available (used by many slash commands):

- **send-text-message** - Send text messages via SMS/RCS
- **send-media-message** - Send media messages (images, videos) via SMS/RCS
- **send-template-message** - Send template messages
- **list-conversation-apps** - List configured apps and channels
- **list-messaging-templates** - List available message templates
- **sinch-mcp-configuration** - Check MCP server configuration status

Other commands (batch, templates API, voice, verification, fax, numbers, email, 10DLC, SIP, provisioning, contacts) use direct API calls with your configured credentials when MCP does not expose a matching tool.

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
sinch-gemini-extension/
├── gemini-extension.json    # Extension manifest (MCP, settings)
├── README.md                # This file
└── commands/               # Slash command definitions (TOML)
    └── sinch/
        ├── api/             # messages, webhooks, batch, templates, voice, verification, fax, numbers, 10dlc, sip, provisioning, contacts
        ├── email/           # mailgun, mailjet
        ├── config/          # auth
        └── help.toml
```

## Examples

### Messaging

```bash
/sinch:api:messages:send --to=+1234567890 --message="Your order is ready"
/sinch:api:messages:send-media --to=+1234567890 --url=https://example.com/photo.jpg
/sinch:api:messages:send-card --to=+1234567890 --title="Welcome" --description="Thanks for signing up"
/sinch:api:webhooks:list
```

### Batch and Templates

```bash
/sinch:api:batch:send --message="Hello ${name}" --recipients=+15551111111,+15552222222
/sinch:api:templates:list
/sinch:api:templates:create --default-language=en-US --text="Hi ${name}!"
```

### Voice and Verification

```bash
/sinch:api:voice:callout --to=+1234567890 --text="This is a test call from Sinch"
/sinch:api:verification:start --to=+1234567890 --method=sms
/sinch:api:verification:check --id=VERIFICATION_ID --code=1234
```

### Fax, Numbers, Email

```bash
/sinch:api:fax:send --to=+1234567890 --content-url=https://example.com/doc.pdf
/sinch:api:numbers:lookup --numbers=+1234567890
/sinch:email:mailgun:send --from="Sender <sender@mydomain.com>" --to=user@example.com --subject="Hello" --text="Hi"
/sinch:email:mailgun:validate --address=user@example.com
```

### Config and Help

```bash
/sinch:help
/sinch:config:auth
```

## API References

- [Sinch Developer Hub](https://developers.sinch.com/) — Conversation, Voice, Verification, Fax, Numbers, 10DLC, etc.
- [Sinch Conversation API](https://developers.sinch.com/docs/conversation)
- [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server)
- [Gemini CLI Extensions](https://geminicli.com/docs/extensions/)
- [Message Templates](https://developers.sinch.com/docs/conversation/templates/)
- [Webhooks](https://developers.sinch.com/docs/conversation/webhooks/)
- [LLMs index](https://developers.sinch.com/llms.txt)

## Contributing

Contributions are welcome! Please check the main repository for contribution guidelines.

## License

See the LICENSE file in the repository root.
