# Sinch Gemini Plugin

Custom slash commands for [Gemini CLI](https://github.com/google-gemini/gemini-cli) that integrate the Sinch Conversation API. Send messages (SMS, RCS), manage webhooks, and inspect your Sinch configuration directly from your terminal.

## Features

- **Send Messages**: Send text messages via SMS or RCS
- **Check Status**: Retrieve delivery events for sent messages
- **Manage Webhooks**: Create, list, update, and delete webhooks for your Conversation API app
- **List Senders**: View active phone numbers and senders with code generation helpers

## Prerequisites

- [Gemini CLI](https://github.com/google-gemini/gemini-cli) installed
- A [Sinch Customer Dashboard](https://dashboard.sinch.com/) account
- A Conversation API app with credentials (Project ID, Key ID, Key Secret, App ID)

## Installation

### Option 1: Install via npm (Recommended)

Once published to npm, install with:

```bash
npm install -g @sinch/gemini-plugin
```

The plugin will automatically install commands to `~/.gemini/commands/sinch/`.

Or use the installation script:

```bash
./install.sh
```

### Option 2: Project-Scoped Installation

Copy the `.gemini` and `scripts` directories to your project root:

```bash
cp -r sinch-gemini-plugin/.gemini /path/to/your/project/
cp -r sinch-gemini-plugin/scripts /path/to/your/project/
```

This makes the commands available only within that specific project.

### Option 3: Manual User-Scoped Installation

Copy the commands and scripts to your home directory to make them available across all projects:

```bash
cp -r sinch-gemini-plugin/.gemini/commands/sinch ~/.gemini/commands/
cp -r sinch-gemini-plugin/scripts/sinch ~/.gemini/scripts/
```

## Configuration

Set the following environment variables in your shell profile (`.zshrc`, `.bashrc`, etc.):

```bash
export CONVERSATION_PROJECT_ID="your-project-id"
export CONVERSATION_KEY_ID="your-key-id"
export CONVERSATION_KEY_SECRET="your-key-secret"
export CONVERSATION_REGION="us"  # or "eu", "br"
export CONVERSATION_APP_ID="your-app-id"
```

Optional (for message status tracking):

```bash
export NGROK_AUTH_TOKEN="your-ngrok-token"
```

### Getting Your Credentials

1. Visit the [Sinch Dashboard](https://dashboard.sinch.com/)
2. Create or select a Conversation API project
3. Create an app and configure channels (SMS, RCS, etc.)
4. Generate API credentials (Access Key)
5. Copy the Project ID, Key ID, Key Secret, Region, and App ID

## Available Commands

### Messages

#### Send a message

```bash
/sinch:messages:send --to=+14155551234 --message="Hello from Sinch"
/sinch:messages:send -t +14155551234 -m "Hello" --channel=RCS
```

#### Get message status

```bash
/sinch:messages:status --message_id=01HXXX123456
/sinch:messages:status -m 01HXXX123456
```

### Webhooks

#### List webhooks

```bash
/sinch:api:webhooks:list
/sinch:api:webhooks:list --format=json
```

#### Create webhook

```bash
/sinch:api:webhooks:create --target=https://example.com/webhook --triggers=MESSAGE_INBOUND
/sinch:api:webhooks:create -t https://example.com/hook -tr MESSAGE_INBOUND,MESSAGE_DELIVERY --secret=my-secret-123456
```

#### Update webhook

```bash
/sinch:api:webhooks:update --id=01E9DQJF... --target=https://new-endpoint.com/webhook
/sinch:api:webhooks:update --id=01E9DQJF... --triggers=MESSAGE_INBOUND,MESSAGE_DELIVERY
```

#### Delete webhook

```bash
/sinch:api:webhooks:delete --id=01E9DQJF...
/sinch:api:webhooks:delete --id=01E9DQJF... --confirm
```

#### List webhook triggers

```bash
/sinch:api:webhooks:triggers
/sinch:api:webhooks:triggers --format=json
```

### Senders

#### List active senders (interactive code generator)

```bash
/sinch:api:senders:list                    # Show menu
/sinch:api:senders:list generate           # Generate code
/sinch:api:senders:list debug              # Troubleshooting
/sinch:api:senders:list explain            # API documentation
/sinch:api:senders:list pagination         # Pagination example
```

## Command Structure

Commands follow a namespaced structure using colons (`:`) as separators:

- `/sinch:api:messages:send` - Maps to `.gemini/commands/sinch/api/messages/send.toml`
- `/sinch:api:webhooks:list` - Maps to `.gemini/commands/sinch/api/webhooks/list.toml`
- `/sinch:api:senders:list` - Maps to `.gemini/commands/sinch/api/senders/list.toml`

## Webhook Triggers

Available webhook triggers include:

**Message Events:**

- `MESSAGE_INBOUND` - Incoming messages from users
- `MESSAGE_DELIVERY` - Delivery receipts
- `MESSAGE_SUBMIT` - Message submission events

**Conversation Events:**

- `CONVERSATION_START` - New conversation
- `CONVERSATION_STOP` - Conversation stopped
- `CONVERSATION_DELETE` - Conversation deleted

**Contact Events:**

- `CONTACT_CREATE`, `CONTACT_UPDATE`, `CONTACT_DELETE`, `CONTACT_MERGE`

**Other Events:**

- `OPT_IN`, `OPT_OUT` - User opt-in/out
- `CAPABILITY` - Channel capability changes
- `CHANNEL_EVENT` - Channel-specific events

See `/sinch:api:webhooks:triggers` for the complete list.

## Troubleshooting

### "Environment variables not configured"

Ensure all required environment variables are set:

```bash
echo $CONVERSATION_PROJECT_ID
echo $CONVERSATION_KEY_ID
echo $CONVERSATION_KEY_SECRET
echo $CONVERSATION_REGION
echo $CONVERSATION_APP_ID
```

### "Channel not configured"

Verify your Conversation app has the channel (SMS/RCS) configured in the Sinch Dashboard.

### Authentication errors

- Verify your Key ID and Key Secret are correct
- Ensure your access key has not expired
- Check that the region matches your app's region

### Message delivery issues

- Ensure phone numbers are in E.164 format (+country_code + number)
- Verify the recipient's carrier supports the channel (SMS/RCS)
- Check webhook configuration for delivery receipts

## API References

- [Sinch Conversation API](https://developers.sinch.com/docs/conversation)
- [Numbers API](https://developers.sinch.com/docs/numbers)
- [Webhooks Documentation](https://developers.sinch.com/docs/conversation/webhooks/)
- [Gemini CLI Custom Commands](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/commands.md#custom-commands)

## Examples

### Send an SMS and check its status

```bash
# Send message
/sinch:api:messages:send --to=+14155551234 --message="Hello"

# Get the message ID from the response, then check status
/sinch:api:messages:status --message_id=01HXXX123456
```

### Set up a webhook for incoming messages

```bash
# Create webhook
/sinch:api:webhooks:create --target=https://myapp.com/webhook --triggers=MESSAGE_INBOUND --secret=secure-secret-key-123

# List to verify
/sinch:api:webhooks:list
```

### Generate code to list active numbers

```bash
/sinch:api:senders:list generate
```

## Contributing

Contributions are welcome! Please check the main repository for contribution guidelines.

## License

See the LICENSE file in the repository root.
