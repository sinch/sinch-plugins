---
name: sinch-mcp-setup
description: Configure Sinch Conversation API credentials
---

Guide the user through setting up Sinch Conversation API credentials.

## Overview

This plugin uses the Sinch Conversation API MCP server (defined in `mcp.json`) to send messages via SMS and RCS channels. The server reads your Sinch credentials from `~/.sinch/mcp.env`, which Cursor loads through the `envFile` option.
For more details about the underlying MCP server and tools, see [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server)

## Required Environment Variables

You need to obtain and configure the following 5 variables:

- `PROJECT_ID` - Your Sinch project ID
- `KEY_ID` - Your API key ID
- `KEY_SECRET` - Your API key secret
- `CONVERSATION_REGION` - Your Sinch region (e.g., `us`, `eu`, `br`)
- `CONVERSATION_APP_ID` - Your Conversation app ID

## How to Get Credentials

Visit the [Sinch Conversation API documentation](https://developers.sinch.com/docs/conversation) for instructions to:

- Create a Sinch account
- Set up a Conversation API project
- Create an app and configure channels
- Generate API credentials (Key ID and Secret)

## Ask Persistence Method

Ask: "How would you like to configure your Sinch credentials?"

Offer these options:

- **Option A: Generate setup script** — interactive bash script that collects credentials and writes ~/.sinch/mcp.env automatically
- **Option B: Manual** — shows instructions to create ~/.sinch/mcp.env yourself

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

4. Restart the `sinch` server in Cursor Settings → MCP, or reload the window

5. Run `/sinch-cursor-plugin:api:messages:send` to verify the connection

If they choose B, proceed to manual instructions below.

## If Option B (Manual):

Tell the user:

1. Create the env file and restrict it to your user:

```bash
   mkdir -p ~/.sinch && chmod 700 ~/.sinch
   touch ~/.sinch/mcp.env && chmod 600 ~/.sinch/mcp.env
   nano ~/.sinch/mcp.env
```

2. Add your credentials, one per line, with no quotes:

```
PROJECT_ID=your-project-id
KEY_ID=your-api-key
KEY_SECRET=your-api-secret
CONVERSATION_REGION=us
CONVERSATION_APP_ID=your-app-id
```

`CONVERSATION_REGION` is `us`, `eu` or `br`.

3. Save the file.

4. Restart the `sinch` server in Cursor Settings → MCP, or reload the window.

5. Run `/sinch-cursor-plugin:api:messages:send` to verify the connection.

## Important Notes

- Credentials are collected directly by the bash script - they are never sent to Cursor
- The API Secret input is hidden (no echo) for security
- The env file is created with owner-only permissions (`chmod 600`)
- Remind user never to copy `~/.sinch/mcp.env` into a project or commit it to version control
