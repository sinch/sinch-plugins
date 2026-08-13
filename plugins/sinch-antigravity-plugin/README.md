# Sinch - Antigravity CLI Plugin

An [Antigravity CLI](https://antigravity.google/docs/cli/plugins) plugin that integrates Sinch APIs: Conversation API (SMS, RCS, WhatsApp), Voice, Verification, Fax, Numbers, 10DLC, Email (Mailgun, Mailjet), and more. Use natural language or slash commands to send messages, make calls, verify numbers, send faxes, and manage configuration.

This is the Antigravity successor to the Gemini CLI extension (`sinch-gemini-extension`). Both ship side by side; existing Gemini users can migrate with `agy plugin import gemini`.

## Prerequisites

- [Antigravity CLI](https://antigravity.google/docs/cli/install) (`agy`) installed and authenticated
- A [Sinch Customer Dashboard](https://dashboard.sinch.com/) account
- A Conversation API app with credentials (Project ID, Key ID, Key Secret, App ID, Region)

## Installation

### From local path (recommended while developing)

```bash
agy plugin install ./plugins/sinch-antigravity-plugin
```

### From this monorepo

```bash
agy plugin install https://github.com/sinch/sinch-plugins
```

Antigravity discovers every plugin under `plugins/` that has a valid manifest. After this plugin is on `main`, the install includes `sinch-antigravity-plugin`.

### From a release tarball

Download `darwin.sinch-antigravity-plugin.tar.gz` (or `linux` / `win32`) from the repository Releases, extract it, then:

```bash
agy plugin install /path/to/extracted/sinch-antigravity-plugin
```

### Migrating from the Gemini CLI extension

If you already have the Sinch Gemini extension installed:

```bash
agy plugin import gemini
```

Validate before install:

```bash
agy plugin validate ./plugins/sinch-antigravity-plugin
```

## MCP servers

This plugin ships two MCP servers (same pairing as PD-318 on Claude / Cursor / Gemini):

| Server | Key | Transport | Purpose |
|--------|-----|-----------|---------|
| **Sinch Build MCP** | `sinch` | stdio (`npx -y @sinch/mcp`) | Conversation API tools (send messages, webhooks, senders). Needs credentials. |
| **Sinch Docs MCP** | `sinch-docs` | remote HTTP (`serverUrl`: `https://developers.sinch.com/mcp`) | Search/read Sinch developer docs. No credentials. |

Antigravity uses `serverUrl` for remote servers (not Gemini’s `httpUrl` or Cursor’s `url`).

## Configuration

Antigravity plugins do **not** prompt for credentials at install time (unlike Gemini CLI extension `settings`). The Docs MCP needs none. For the Build MCP, export environment variables in your shell before starting `agy`:

```bash
export CONVERSATION_PROJECT_ID="your-project-id"
export CONVERSATION_KEY_ID="your-key-id"
export CONVERSATION_KEY_SECRET="your-key-secret"
export CONVERSATION_REGION="us"   # us | eu | br
export CONVERSATION_APP_ID="your-app-id"
```

Optional product credentials (same names as the Gemini extension):

- Voice: `VOICE_APPLICATION_KEY`, `VOICE_APPLICATION_SECRET`
- Verification: `VERIFICATION_APPLICATION_KEY`, `VERIFICATION_APPLICATION_SECRET`
- Mailgun: `MAILGUN_API_KEY`, `MAILGUN_DOMAIN`, `MAILGUN_REGION`
- Mailjet: `MJ_APIKEY_PUBLIC`, `MJ_APIKEY_PRIVATE`

The bundled `mcp_config.json` passes `${CONVERSATION_*}` through to `npx -y @sinch/mcp`. Those placeholders are preserved as-is at install time; set the real values in the process environment.

Restart `agy` after changing env vars.

## Verify installation

```bash
agy plugin list
```

You should see `sinch-antigravity-plugin` with components `skills` and `mcpServers`, and `agy plugin validate` should report 53 skills (38 Sinch workflows plus 15 product skills).

Inside an `agy` session, open `/mcp` to confirm both `sinch` (Build) and `sinch-docs` are connected.

## Usage

Start Antigravity CLI (`agy`) and use natural language or slash commands. Every Gemini CLI slash command was migrated to an Antigravity skill under `skills/<name>/SKILL.md`; Antigravity registers each skill as a slash command of the same name.

### Slash commands (examples)

| Category | Commands |
|----------|----------|
| **Help / Auth** | `/sinch-help`, `/sinch-config-auth` |
| **Messages** | `/sinch-api-messages-send`, `send-media`, `send-card`, `send-carousel`, `send-choice`, `send-location`, `list` |
| **Webhooks** | `/sinch-api-webhooks-create`, `list`, `update`, `delete`, `triggers` |
| **Senders** | `/sinch-api-senders-list` |
| **Batch** | `/sinch-api-batch-send`, `status` |
| **Templates** | `/sinch-api-templates-list`, `create`, `delete` |
| **Voice** | `/sinch-api-voice-callout`, `calls` |
| **Verification** | `/sinch-api-verification-start`, `check` |
| **Fax** | `/sinch-api-fax-send`, `list` |
| **Numbers** | `/sinch-api-numbers-lookup`, `search` |
| **10DLC** | `/sinch-api-10dlc-brands`, `campaigns` |
| **SIP** | `/sinch-api-sip-trunks` |
| **Provisioning** | `/sinch-api-provisioning-setup` |
| **Contacts** | `/sinch-api-contacts-list` |
| **Email** | `/sinch-email-mailgun-send`, `validate`, `inspect`, `optimize`; `/sinch-email-mailjet-send` |

Product skills from `sinch-skills` (conversation-api, voice-api, numbers, mailgun, …) are installed under `skills/` alongside the migrated workflow skills.

## Plugin structure

```
sinch-antigravity-plugin/
├── plugin.json          # Antigravity manifest (name + description only)
├── mcp_config.json      # Build MCP (stdio) + Docs MCP (serverUrl)
├── README.md
└── skills/
    ├── sinch-api-messages-send/SKILL.md   # migrated Gemini commands (38)
    └── conversation-api/                  # symlinks into vendor/sinch-skills (15)
```

`plugin.json` cannot carry version, author, or license fields (`additionalProperties: false`). Metadata lives here and in the repository root README.

## Known limitations

- No interactive credential prompts; export env vars yourself.
- Antigravity has no runtime command primitive. Gemini's `commands/sinch/**/*.toml` were converted to `skills/<name>/SKILL.md`; keeping them as TOML under `commands/` in a native plugin leaves them unregistered as slash commands.
- Skill names are namespaced (`sinch-api-messages-send`) rather than Gemini's short names (`send`), which collided with each other during `agy plugin import gemini`.
- Remote git install against the monorepo root installs every plugin under `plugins/`, not only this one.
- `${extensionPath}` path substitution is not required here (MCP uses `npx` on `PATH`).

## Plugin management

```bash
agy plugin list
agy plugin disable sinch-antigravity-plugin
agy plugin enable sinch-antigravity-plugin
agy plugin uninstall sinch-antigravity-plugin
```

## API references

- [Sinch Developer Hub](https://developers.sinch.com/)
- [Sinch Conversation API](https://developers.sinch.com/docs/conversation)
- [Sinch MCP Server](https://github.com/sinch/sinch-mcp-server)
- [Antigravity CLI Plugins](https://antigravity.google/docs/cli/plugins)
- [Migrating from Gemini CLI](https://antigravity.google/docs/cli/gcli-migration)

## License

See the LICENSE file in the repository root.
