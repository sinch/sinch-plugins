---
name: sinch-mcp-setup
description: Configure Sinch Conversation API credentials
---

Guide the user through setting up Sinch Conversation API credentials.

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

Visit the [Sinch Conversation API documentation](https://developers.sinch.com/docs/conversation) for instructions to:

- Create a Sinch account
- Set up a Conversation API project
- Create an app and configure channels
- Generate API credentials (Key ID and Secret)

## Ask Persistence Method

Ask: "How would you like to configure your Sinch credentials?"

Offer these options:

- **Option A: Generate setup script** — interactive bash script that collects credentials and updates ~/.claude/settings.json automatically
- **Option B: Manual** — shows instructions to edit ~/.claude/settings.json yourself

## If Option A (Setup script):

Generate this bash script from the template @./init_mcp_cred.sh that bundled with this command. Save the generated script to the current terminal location. If not possible, save it to user home directory. Don't need to display the whole script content unless user requests it so it don't clutter the output.

If saving is not possible, ask the user to choose A: "Display the script for manual copy-paste" or B: "Switch to manual instructions".
If they choose A, display the script content in a code block.
Then tell the user:

1. Save the script to a file:

```bash
   nano ~/sinch-setup.sh
```

Paste the script, then save (Ctrl+O, Enter, Ctrl+X)

2. Make it executable:

```bash
   chmod +x ~/sinch-setup.sh
```

3. Run it:

```bash
   bash ~/sinch-setup.sh
```

4. Restart Claude Code to load the new environment variables

5. Run `/sinch:status` to verify the connection

If they choose B, proceed to manual instructions below.

## If Option B (Manual):

Tell the user:

1. Open or create `~/.claude/settings.json`:

```bash
   mkdir -p ~/.claude
   [[ -f ~/.claude/settings.json ]] || echo '{}' > ~/.claude/settings.json
   nano ~/.claude/settings.json
```

2. Add or merge the `env` block with your credentials:

```json
{
  "env": {
    "CONVERSATION_PROJECT_ID": "your-project-id",
    "CONVERSATION_KEY_ID": "your-api-key",
    "CONVERSATION_KEY_SECRET": "your-api-secret",
    "CONVERSATION_REGION": "us",
    "CONVERSATION_APP_ID": "your-app-id"
  }
}
```

3. If your file already has other content in the `env` block, add the 5 `CONVERSATION_*` keys without removing existing values.

4. Save the file.

5. Restart Claude Code.

6. Run `/sinch-conversation-api:api:messages:send` to verify the connection.

## Important Notes

- Credentials are collected directly by the bash script — they are never sent to Claude
- The API Secret input is hidden (no echo) for security
- Remind user not to commit `~/.claude/settings.json` to version control
