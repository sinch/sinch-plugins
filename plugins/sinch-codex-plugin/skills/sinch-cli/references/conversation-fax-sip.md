> **Summary — not the spec.** This file orients you to a CLI command family. The
> authoritative source for exact flags and argument order is `sinch <cmd> --help` on
> the installed binary; the linked `developers.sinch.com` docs are authoritative for
> concepts but may lag the shipped CLI. Do **not** copy a flag name, argument order, or
> enum value from here into a shipped script without confirming it against `--help`.
> See "Source of Truth" in this skill's SKILL.md.

# Conversation, Fax, and SIP Trunking CLI

Reference for `sinch conversation` (omnichannel messaging), `sinch fax`, and `sinch sip` (Elastic SIP Trunking). Loaded on-demand from [SKILL.md](../SKILL.md).

## Conversation messaging (`sinch conversation`)

Send SMS, WhatsApp, RCS, and other messages through the unified Conversation API. SMS is sent via `sinch conversation send --channel SMS`, **not** a separate `sinch sms` command.

```bash
# Interactive wizard — prompts for channel, recipient, message type
sinch conversation send

# Direct SMS
sinch conversation send +15551234567 "Hello from Sinch" --channel SMS

# WhatsApp with media
sinch conversation send +15551234567 \
  --channel WHATSAPP \
  --media https://example.com/image.jpg \
  --caption "Check this out"

# Template message
sinch conversation send +15551234567 \
  --channel WHATSAPP \
  --type template \
  --template welcome_template \
  --params '{"name":"Alice"}'

# Raw JSON escape hatch for any message structure
sinch conversation send +15551234567 -c WHATSAPP \
  --json-message '{"text_message":{"text":"hi"}}'
```

**Channels:** `SMS`, `WHATSAPP`, `MESSENGER`, `INSTAGRAM`, `VIBER`, `TELEGRAM`, `RCS`, `LINE`

**Message types:** `text`, `media`, `template`, `card`, `carousel`, `choice`, `location`, `list`

### Management commands

```bash
sinch conversation apps list                       # list Conversation apps
sinch conversation apps create [name]              # create a new Conversation app
sinch conversation apps get <id>                   # get app details
sinch conversation apps delete <id>                # delete an app

sinch conversation contacts --limit 20             # list contacts
sinch conversation conversations --state ACTIVE    # list conversations by state
sinch conversation messages list --channel WHATSAPP
sinch conversation messages get <id>               # get a specific message
sinch conversation messages delete <id>            # delete a message
sinch conversation messages update <id> --metadata <json>

sinch conversation webhooks list --app app_abc     # list webhooks for an app
sinch conversation webhooks create                 # interactive
sinch conversation webhooks update <id>
sinch conversation webhooks delete <id>

sinch conversation templates list                  # list message templates
sinch conversation templates get <id>              # with translations
sinch conversation templates create                # interactive
sinch conversation templates delete <id>
```

## Fax (`sinch fax`)

```bash
# One-time setup
sinch config set fax serviceID=<your-service-id>
sinch config set fax senderNumber=+15551234567

# Send a fax from a file
sinch fax send --to +12025550134 --file ./document.pdf

# Send from URL
sinch fax send --to +12025550134 --content-url https://example.com/doc.pdf

# Track status
sinch fax status <fax-id> --wait --timeout 600
sinch fax status <fax-id> --watch --interval 5
sinch fax get <fax-id>

# List configured fax services (verify setup)
sinch fax services list
```

**Supported file types:** PDF, TIFF, DOC, DOCX, TXT, HTML (max 20 MB).

### Fax status flags

| Flag | Description |
|---|---|
| `--wait` | Poll until the fax completes or fails |
| `--timeout <seconds>` | Timeout for `--wait` (default: 300) |
| `--watch` | Continuously poll and redisplay status |
| `--interval <seconds>` | Poll interval for `--watch` (default: 5) |

## Elastic SIP Trunking (`sinch sip`)

Manage SIP trunks, endpoints, ACLs, calls, credential lists, and countries.

```bash
# Manage SIP trunks
sinch sip trunks list
sinch sip trunks create --name "main-trunk" --host-name sip.example.com
sinch sip trunks update <trunk-id> --caller-id
sinch sip trunks delete <trunk-id>

# Endpoints (registered SIP devices)
sinch sip endpoints list --json
sinch sip endpoints create
sinch sip endpoints update <endpoint-id>
sinch sip endpoints delete <endpoint-id>

# ACLs (IP allowlists)
sinch sip acls list
sinch sip acls create
sinch sip acls update <acl-id>
sinch sip acls delete <acl-id>

# Trunk ACL and credential list assignment
sinch sip trunks acls add <trunk-id> <acl-id>
sinch sip trunks acls remove <trunk-id> <acl-id>
sinch sip trunks credential-lists update <trunk-id> <cred-list-id...>

# Credential lists (username/password pairs)
sinch sip credential-lists list
sinch sip credential-lists create
sinch sip credential-lists delete <list-id>

# Call history
sinch sip calls list --trunk <id> --from 2026-01-01 --limit 50
sinch sip calls get <call-id>

# Supported countries
sinch sip countries
```

All SIP subcommands support `--json`. Create and update commands support `--non-interactive` for CI/CD use.

## Related

- [CLI skill](../SKILL.md) — full CLI overview
- [Conversation commands docs](https://developers.sinch.com/docs/functions/cli/commands/conversation.md)
- [Fax commands docs](https://developers.sinch.com/docs/functions/cli/commands/fax.md)
- [SIP commands docs](https://developers.sinch.com/docs/functions/cli/commands/sip-trunking.md)
- [Conversation API](https://developers.sinch.com/docs/conversation.md)
- [Elastic SIP Trunking](https://developers.sinch.com/docs/est.md)
