# Sinch Plugins

This repository contains Sinch plugins and related artifacts for AI developer tools.

## Claude Code

A Claude Code plugin that integrates the Sinch Conversation API, allowing you to send messages (SMS, RCS, etc.), manage webhooks, and inspect your Sinch configuration directly from your terminal.

### Features

- **Send Messages**: Send text messages via SMS, RCS.
- **Check Status**: Retrieve delivery events for sent messages.
- **Manage Webhooks**: Create, list, update, and delete webhooks for your Conversation API app.
- **List Senders**: View active phone numbers and senders.
- **MCP Integration**: Built on top of the Model Context Protocol (MCP).

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) installed.
- A [Sinch Customer Dashboard](https://dashboard.sinch.com/) account.
- A Conversation API app with credentials (Project ID, Key ID, Key Secret, App ID, App Region).

### Installation

To install this plugin in Claude Code, you typically install it from a marketplace or a local source.

```bash
/plugin marketplace add https://github.com/sinch/sinch-plugins.git
/plugin install sinch-claude-plugin
```

### Configuration

This plugin relies on the Sinch MCP server, which requires specific environment variables to authenticate with the Sinch API. These variables must be set in your Claude Code settings.

### Required Environment Variables

You need to configure the following variables:

- `CONVERSATION_PROJECT_ID`: Your Sinch Project ID.
- `CONVERSATION_KEY_ID`: Your Access Key ID.
- `CONVERSATION_KEY_SECRET`: Your Access Key Secret.
- `CONVERSATION_REGION`: The region for your app (e.g., `us`, `eu`, `br`).
- `CONVERSATION_APP_ID`: The specific Conversation App ID you want to use.
- `NGROK_AUTH_TOKEN` (Optional): Required if you want to use features that need a public callback URL for local testing.

### Get Your Sinch Credentials

Get access and create your access key: You will need a Sinch Build account ([see here for instructions on setting up an account](https://community.sinch.com/t5/Build-Dashboard/How-to-sign-up-for-your-free-Sinch-account/ta-p/8058)). Once you have created an account and logged in, select [Conversation API](https://dashboard.sinch.com/convapi/overview) from the left menu. Review the terms and conditions, select the I agree to the terms and conditions check box, and click GET ACCESS to proceed.
Then, create your access key. Access keys are used to authenticate calls when using Conversation API. Access keys are generated in the [Sinch Build Dashboard](https://dashboard.sinch.com/settings/access-keys). If you need assistance, you can [review our Community article on access key creation](https://community.sinch.com/t5/Conversation-API/How-to-get-your-access-key-for-Conversation-API/ta-p/8120).

### Setup Methods

#### Option 1: Automated Setup (Recommended)

We provide setup scripts to help you configure these variables interactively.

**macOS / Linux:**
Run the shell script located in the plugin configuration folder:

```bash
./plugins/sinch-claude-plugin/commands/config/init_mcp_cred.sh
```

#### Option 2: Manual Configuration

1. Open your Claude Code settings file. On macOS/Linux, this is usually `~/.claude/settings.json`.
2. Add or update the `env` object with your credentials:

```json
{
  "env": {
    "CONVERSATION_PROJECT_ID": "your-project-id",
    "CONVERSATION_KEY_ID": "your-key-id",
    "CONVERSATION_KEY_SECRET": "your-key-secret",
    "CONVERSATION_REGION": "your-app-region (e.g., us, eu, br)",
    "CONVERSATION_APP_ID": "your-app-id"
  }
}
```

3. **Restart Claude Code** for the changes to take effect.

### Usage

Once installed and configured, you can use natural language or specific slash commands to interact with the API.

### Common Commands

- **Setup Help**:

  ```
  /sinch-claude-plugin:sinch-help
  ```

- **Send a Message**:

  ```
  /sinch-claude-plugin:api:messages:send --to=+15551234567 --message="Hello from Claude!"
  ```

- **List Webhooks**:

  ```
  /sinch-claude-plugin:api:webhooks:list
  ```

- **Check Message Status**:

  ```
  /sinch-claude-plugin:api:messages:status --message_id=MESSAGE_ID
  ```

- **List Active Senders**:
  ```
  /sinch-claude-plugin:api:senders:list
  ```

### Architecture

This plugin leverages the [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server) to communicate with the Sinch Conversation API. It defines a set of tools and prompts that Claude Code uses to perform actions on your behalf.

## Skills

Skills are natural-language workflows that guide Claude through common tasks.

- Skills live under [plugins/sinch-claude-plugin/skills](plugins/sinch-claude-plugin/skills/).
- Skills are also published as a standalone artifact in this repository's Releases.

Available skills:

- [Send Message](plugins/sinch-claude-plugin/skills/send-message/SKILL.md)
- [Channel Info](plugins/sinch-claude-plugin/skills/channel-info/SKILL.md)
- [List Messages](plugins/sinch-claude-plugin/skills/list-messages/SKILL.md)
- [Manage Contact](plugins/sinch-claude-plugin/skills/manage-contact/SKILL.md)
- [Manage Webhook](plugins/sinch-claude-plugin/skills/manage-webhook/SKILL.md)

## Gemini CLI

A Gemini CLI extension that integrates the Sinch Conversation API, allowing you to send messages (SMS, RCS), manage webhooks, and interact with your Sinch configuration directly from Gemini CLI.

### Installation

#### Install from GitHub

```bash
gemini extensions install https://github.com/sinch/sinch-plugins --ref main
```

#### Install from Local Path

```bash
cd sinch-plugins/plugins/sinch-gemini-extension/.gemini-extension
gemini extensions install .
```

### Configuration

During installation, Gemini CLI will automatically prompt you for your Sinch credentials:

- **CONVERSATION_PROJECT_ID**: Your Sinch project ID (required)
- **CONVERSATION_KEY_ID**: Your API key ID (required)
- **CONVERSATION_KEY_SECRET**: Your API key secret (required, stored securely)
- **CONVERSATION_REGION**: Your region (us, eu, or br) (required)
- **CONVERSATION_APP_ID**: Your Sinch Conversation API App ID (required)
- **NGROK_AUTH_TOKEN**: (Optional) Ngrok token for message status tracking

### Verify Installation

```bash
# List installed extensions
gemini extensions list

# View extension settings
gemini extensions settings list sinch
```

### Usage

Once installed, restart Gemini CLI and use the available commands:

```bash
# Start Gemini CLI
gemini

# Send a message
/sinch:api:messages:send --to=+14155551234 --message="Hello from Sinch"

# List webhooks
/sinch:api:webhooks:list

# Check message status
/sinch:api:messages:status --message_id=01HXXX123456
```

### Available Commands

- `/sinch:api:messages:send` - Send SMS/RCS messages
- `/sinch:api:messages:status` - Get message delivery status
- `/sinch:api:webhooks:list` - List webhooks
- `/sinch:api:webhooks:create` - Create webhook
- `/sinch:api:webhooks:update` - Update webhook
- `/sinch:api:webhooks:delete` - Delete webhook
- `/sinch:api:webhooks:triggers` - List available triggers
- `/sinch:api:senders:list` - List active senders

### Managing Settings

```bash
# View extension settings
gemini extensions settings list sinch

# Update a setting
gemini extensions settings set sinch "Key Secret"
```

### Extension Management

```bash
# Update extension
gemini extensions update sinch

# Disable extension
gemini extensions disable sinch

# Enable extension
gemini extensions enable sinch

# Uninstall extension
gemini extensions uninstall sinch
```

For detailed documentation, see [plugins/sinch-gemini-extension/.gemini-extension/README.md](plugins/sinch-gemini-extension/.gemini-extension/README.md).

## License

Apache-2.0

Copyright Sinch AB, https://sinch.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Further Reading

Developer Documentation: [https://developers.sinch.com/docs/conversation/](https://developers.sinch.com/docs/conversation/)

---

## Feedback, Issues and Support

We love hearing feedback, and we are here to help if you run into any issues.

- For any Sinch Conversation API related issues, or support you require, head over to the [Sinch Help Centre](https://sinch.com/help-center/)

We will continue to enhance this product, so keep a look out for additional channel support (RCS, MMS, WhatsApp etc) in addition to new features in future.

From all of us at Sinch, happy coding!
