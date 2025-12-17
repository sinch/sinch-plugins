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
- A Conversation API app with credentials (Project ID, Key ID, Key Secret, App ID).

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

A Gemini CLI plugin that integrates the Sinch Conversation API, allowing you to send messages (SMS, RCS), manage webhooks, and inspect your Sinch configuration directly from your terminal using Google's Gemini AI.

### Features

- **Send Messages**: Send text messages via SMS or RCS with MCP integration or direct API calls
- **Check Status**: Retrieve delivery events for sent messages
- **Manage Webhooks**: Create, list, update, and delete webhooks for your Conversation API app
- **List Senders**: View active phone numbers and senders with code generation helpers
- **Interactive Mode**: Commands work with or without arguments - prompts you when needed
- **MCP Fallback**: Automatically uses MCP server when available, falls back to direct API calls otherwise

### Prerequisites

- [Gemini CLI](https://github.com/google-gemini/gemini-cli) installed
- A [Sinch Customer Dashboard](https://dashboard.sinch.com/) account
- A Conversation API app with credentials (Project ID, Key ID, Key Secret, App ID)
- Optional: [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server) for enhanced functionality

### Installation

#### Option 1: Install via Script (Recommended)

```bash
cd plugins/sinch-gemini-plugin
./install.sh
```

The plugin will automatically install commands to `~/.gemini/commands/sinch/`.

#### Option 2: Manual User-Scoped Installation

Copy the commands to your home directory to make them available across all projects:

```bash
cp -r plugins/sinch-gemini-plugin/.gemini/commands/sinch ~/.gemini/commands/
```

#### Option 3: Project-Scoped Installation

Copy the `.gemini` directory to your project root:

```bash
cp -r plugins/sinch-gemini-plugin/.gemini /path/to/your/project/
```

This makes the commands available only within that specific project.

### Configuration

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

#### Getting Your Credentials

1. Visit the [Sinch Dashboard](https://dashboard.sinch.com/)
2. Create or select a Conversation API project
3. Create an app and configure channels (SMS, RCS, etc.)
4. Generate API credentials (Access Key)
5. Copy the Project ID, Key ID, Key Secret, Region, and App ID

### Usage

Commands can be used with arguments or in interactive mode:

#### With Arguments:

```bash
/sinch:api:messages:send --to=+14155551234 --message="Hello from Sinch"
```

#### Interactive Mode (no arguments):

```bash
/sinch:api:messages:send
# Gemini will prompt you for:
# 📱 What is the recipient's phone number?
# 💬 What message do you want to send?
# 📡 Which channel? (SMS or RCS)
```

#### Natural Language:

```bash
/sinch:api:messages:send please help me send a message to +14155551234
```

### Available Commands

#### Messages

**Send a message:**

```bash
/sinch:api:messages:send --to=+14155551234 --message="Hello"
/sinch:api:messages:send -t +14155551234 -m "Hello" --channel=RCS
```

**Get message status:**

```bash
/sinch:api:messages:status --message_id=01HXXX123456
/sinch:api:messages:status -m 01HXXX123456
```

#### Webhooks

**List webhooks:**

```bash
/sinch:api:webhooks:list
/sinch:api:webhooks:list --format=json
```

**Create webhook:**

```bash
/sinch:api:webhooks:create --target=https://example.com/webhook --triggers=MESSAGE_INBOUND
/sinch:api:webhooks:create -t https://example.com/hook -T MESSAGE_INBOUND,MESSAGE_DELIVERY -s my-secret-123456
```

**Update webhook:**

```bash
/sinch:api:webhooks:update --id=01E9DQJF... --target=https://new-endpoint.com/webhook
/sinch:api:webhooks:update -i 01E9DQJF... -T MESSAGE_INBOUND,MESSAGE_DELIVERY
```

**Delete webhook:**

```bash
/sinch:api:webhooks:delete --id=01E9DQJF...
/sinch:api:webhooks:delete -i 01E9DQJF... --force
```

**List webhook triggers:**

```bash
/sinch:api:webhooks:triggers
```

#### Senders

**List active senders (interactive):**

```bash
/sinch:api:senders:list
```

### Command Structure

Commands follow a namespaced structure using colons (`:`) as separators:

- `/sinch:api:messages:send` - Maps to `.gemini/commands/sinch/api/messages/send.toml`
- `/sinch:api:webhooks:list` - Maps to `.gemini/commands/sinch/api/webhooks/list.toml`
- `/sinch:api:senders:list` - Maps to `.gemini/commands/sinch/api/senders/list.toml`

### Architecture

This plugin provides custom slash commands for Gemini CLI that:

1. **Try MCP first**: If the [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server) is available, commands will use MCP tools (`mcp__sinch__send-text-message`, `mcp__sinch__get-message-events`, etc.)
2. **Fallback to direct API**: If MCP is not available, commands automatically make direct API calls using environment variables
3. **Interactive prompts**: All commands support interactive mode when called without arguments

This dual approach ensures commands work in any environment, with or without MCP server setup.

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
