# Gemini Plugin vs Claude Plugin

This document explains the key differences between the Sinch Gemini Plugin and the Sinch Claude Plugin.

## Architecture Differences

### Claude Plugin

- Uses **Markdown (.md) files** for command definitions
- Integrates with **Model Context Protocol (MCP)** servers
- Commands reference MCP tools like `mcp__sinch__send-text-message`
- Settings stored in `~/.claude/settings.json`
- Plugin structure: `commands/` with nested `.md` files

### Gemini Plugin

- Uses **TOML (.toml) files** for command definitions
- Works with **Gemini CLI** slash commands
- Commands contain complete prompt instructions
- Environment variables configured in shell profile
- Plugin structure: `.gemini/commands/` with nested `.toml` files

## File Structure Comparison

### Claude Plugin

```
sinch-claude-plugin/
├── commands/
│   ├── sinch-help.md
│   ├── config/
│   │   └── sinch-mcp-setup.md
│   └── api/
│       ├── messages/
│       │   ├── send.md
│       │   └── status.md
│       ├── senders/
│       │   └── list.md
│       └── webhooks/
│           ├── list.md
│           ├── create.md
│           ├── update.md
│           ├── delete.md
│           └── triggers.md
└── skills/
```

### Gemini Plugin

```
sinch-gemini-plugin/
├── .gemini/
│   └── commands/
│       └── sinch/
│           └── api/
│               ├── messages/
│               │   ├── send.toml
│               │   └── status.toml
│               ├── senders/
│               │   └── list.toml
│               └── webhooks/
│                   ├── list.toml
│                   ├── create.toml
│                   ├── update.toml
│                   ├── delete.toml
│                   └── triggers.toml
├── README.md
└── install.sh
```

## Command Format Comparison

### Claude Plugin Command

```markdown
---
description: Send a text message via Sinch Conversation API
allowed-tools:
  - mcp__sinch__send-text-message
  - mcp__sinch__sinch-mcp-configuration
argument-hint: --to=<phone> --message=<text>
---

# Send Message

Instructions for the AI to call MCP tools...
```

**Usage:**

```bash
/sinch-claude-plugin:api:messages:send --to=+1234567890 --message="Hello"
```

### Gemini Plugin Command

```toml
description = "Send a text message via Sinch Conversation API"

prompt = """
Instructions for the AI to:
1. Parse arguments
2. Validate inputs
3. Make API calls directly
4. Handle responses
...
"""
```

**Usage:**

```bash
/sinch:api:messages:send --to=+1234567890 --message="Hello"
```

## Command Naming

### Claude Plugin

- Uses full plugin name prefix
- Format: `/sinch-claude-plugin:api:category:command`
- Example: `/sinch-claude-plugin:api:messages:send`

### Gemini Plugin

- Uses namespace prefix only
- Format: `/sinch:api:category:command`
- Example: `/sinch:api:messages:send`

## Configuration

### Claude Plugin

1. Install plugin via marketplace
2. Configure in `~/.claude/settings.json`:

```json
{
  "env": {
    "CONVERSATION_PROJECT_ID": "...",
    "CONVERSATION_KEY_ID": "...",
    ...
  }
}
```

3. Restart Claude Code

### Gemini Plugin

1. Copy commands to `~/.gemini/commands/` or project `.gemini/commands/`
2. Set environment variables in shell profile:

```bash
export CONVERSATION_PROJECT_ID="..."
export CONVERSATION_KEY_ID="..."
...
```

3. Restart terminal/Gemini CLI

## Execution Model

### Claude Plugin

- Claude Code calls MCP tools
- MCP server handles API communication
- Server-side execution with OAuth2
- MCP tools abstract API complexity

### Gemini Plugin

- Gemini CLI executes prompts
- AI generates and runs API calls directly
- Can use shell commands: `!{command}`
- More flexible but requires AI to handle API logic

## Installation

### Claude Plugin

```bash
/plugin marketplace add https://github.com/sinch/sinch-plugins.git
/plugin install sinch-claude-plugin
```

### Gemini Plugin

```bash
# User-scoped
cp -r .gemini/commands/sinch ~/.gemini/commands/

# Or project-scoped
cp -r .gemini ~/.
```

Or use the install script:

```bash
./install.sh
```

## Available Commands

Both plugins provide the same core functionality:

| Feature          | Claude Command                               | Gemini Command                 |
| ---------------- | -------------------------------------------- | ------------------------------ |
| Send message     | `/sinch-claude-plugin:api:messages:send`     | `/sinch:api:messages:send`     |
| Message status   | `/sinch-claude-plugin:api:messages:status`   | `/sinch:api:messages:status`   |
| List webhooks    | `/sinch-claude-plugin:api:webhooks:list`     | `/sinch:api:webhooks:list`     |
| Create webhook   | `/sinch-claude-plugin:api:webhooks:create`   | `/sinch:api:webhooks:create`   |
| Update webhook   | `/sinch-claude-plugin:api:webhooks:update`   | `/sinch:api:webhooks:update`   |
| Delete webhook   | `/sinch-claude-plugin:api:webhooks:delete`   | `/sinch:api:webhooks:delete`   |
| Webhook triggers | `/sinch-claude-plugin:api:webhooks:triggers` | `/sinch:api:webhooks:triggers` |
| List senders     | `/sinch-claude-plugin:api:senders:list`      | `/sinch:api:senders:list`      |

## Key Advantages

### Claude Plugin

- ✅ Tighter MCP integration
- ✅ Server-side API handling
- ✅ More robust error handling
- ✅ Centralized authentication via MCP server

### Gemini Plugin

- ✅ Simpler installation (just copy files)
- ✅ More flexible prompting
- ✅ Can execute shell commands inline
- ✅ Lighter weight (no MCP server needed)
- ✅ Easier to customize and extend

## Which One to Use?

**Use Claude Plugin if:**

- You're using Claude Code as your primary AI assistant
- You want MCP integration
- You need reliable, server-side API handling

**Use Gemini Plugin if:**

- You're using Gemini CLI
- You want simple, file-based commands
- You prefer direct environment variable configuration
- You need to customize prompts easily

Both plugins use the same Sinch API and provide equivalent functionality!
