# Sinch Conversation API Plugin for Claude Code

A Claude Code plugin that integrates the Sinch Conversation API, allowing you to send messages (SMS, WhatsApp, RCS, etc.), manage webhooks, and inspect your Sinch configuration directly from your terminal.

## Features

- **Send Messages**: Send text messages via SMS, RCS, and WhatsApp.
- **Check Status**: Retrieve delivery events for sent messages.
- **Manage Webhooks**: Create, list, update, and delete webhooks for your Conversation API app.
- **List Senders**: View active phone numbers and senders.
- **MCP Integration**: Built on top of the Model Context Protocol (MCP).

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) installed.
- A [Sinch Customer Dashboard](https://dashboard.sinch.com/) account.
- A Conversation API app with credentials (Project ID, Key ID, Key Secret, App ID).

## Installation

To install this plugin in Claude Code, you typically install it from a marketplace or a local source.

```bash
/plugin install sinch-conversation-api
```

## Configuration

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
./plugins/sinch-conversation-api/commands/config/init_mcp_cred.sh
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
    "CONVERSATION_REGION": "us",
    "CONVERSATION_APP_ID": "your-app-id"
  }
}
```

3. **Restart Claude Code** for the changes to take effect.

## Usage

Once installed and configured, you can use natural language or specific slash commands to interact with the API.

### Common Commands

- **Setup Help**:

  ```
  /sinch-conversation-api:sinch-help
  ```

- **Send a Message**:

  ```
  /sinch-conversation-api:api:messages:send --to=+15551234567 --message="Hello from Claude!"
  ```

- **List Webhooks**:

  ```
  /sinch-conversation-api:api:webhooks:list
  ```

- **Check Message Status**:

  ```
  /sinch-conversation-api:api:messages:status --message_id=MESSAGE_ID
  ```

- **List Active Senders**:
  ```
  /sinch-conversation-api:api:senders:list
  ```

## Architecture

This plugin leverages the [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server) to communicate with the Sinch Conversation API. It defines a set of tools and prompts that Claude Code uses to perform actions on your behalf.

## License

Apache-2.0
